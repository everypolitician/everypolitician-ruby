require 'everypolitician/version'
require 'json'
require 'open-uri'
require 'everypolitician/popolo'

module Everypolitician
  class Error < StandardError; end

  class << self
    attr_writer :countries_json
  end

  def self.countries_json
    @countries_json ||= 'https://raw.githubusercontent.com/' \
      'everypolitician/everypolitician-data/master/countries.json'
  end

  def self.country(slug)
    Country.find(slug)
  end

  def self.legislature(country_slug, legislature_slug)
    Legislature.find(country_slug, legislature_slug)
  end

  def self.country_legislature(country_slug, legislature_slug)
    country = Country.find(country_slug)
    legislature = country.legislature(legislature_slug)
    [country, legislature]
  end

  def self.countries
    CountriesJson.new.countries.map { |c| Country.new(c) }
  end

  class Country
    attr_reader :name
    attr_reader :code
    attr_reader :slug
    attr_reader :raw_data

    def self.find(query)
      query = { slug: query } if query.is_a?(String)
      country = CountriesJson.new.find { |c| query.all? { |k, v| c[k] == v } }
      fail Error, "Couldn't find country for query: #{query}" if country.nil?
      new(country)
    end

    def initialize(country_data)
      @name = country_data[:name]
      @code = country_data[:code]
      @slug = country_data[:slug]
      @raw_data = country_data
    end

    def legislatures
      @legislatures ||= @raw_data[:legislatures].map { |l| Legislature.new(l) }
    end

    def legislature(slug)
      legislature = legislatures.find { |l| l.slug == slug }
      fail Error, "Unknown legislature slug: #{slug}" if legislature.nil?
      legislature
    end
  end

  class Legislature
    attr_reader :name
    attr_reader :slug
    attr_reader :lastmod
    attr_reader :person_count
    attr_reader :sha
    attr_reader :raw_data

    def self.find(country_slug, legislature_slug)
      Country.find(country_slug).legislature(legislature_slug)
    end

    def initialize(legislature_data)
      @name = legislature_data[:name]
      @slug = legislature_data[:slug]
      @lastmod = legislature_data[:lastmod]
      @person_count = legislature_data[:person_count]
      @sha = legislature_data[:sha]
      @raw_data = legislature_data
    end

    def popolo
      @popolo ||= Everypolitician::Popolo.parse(open(popolo_url).read)
    end

    def popolo_url
      @popolo_url ||= 'https://raw.githubusercontent.com/everypolitician' \
        "/everypolitician-data/master/#{raw_data[:popolo]}"
    end

    def legislative_periods
      @legislative_periods ||= raw_data[:legislative_periods]
    end
  end

  class CountriesJson
    include Enumerable

    def countries
      @countries ||= JSON.parse(raw_json_string, symbolize_names: true)
    end

    def each(&block)
      countries.each(&block)
    end

    private

    def raw_json_string
      @json ||= open(Everypolitician.countries_json).read
    end
  end
end

# Alternative constant name which is how it's usually capitalized in public copy.
EveryPolitician ||= Everypolitician
