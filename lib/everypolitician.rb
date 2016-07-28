require 'everypolitician/version'
require 'json'
require 'open-uri'
require 'everypolitician/popolo'
require 'csv'

module Everypolitician
  class Error < StandardError; end

  class << self
    attr_writer :countries_json
    attr_writer :countries
  end

  def self.countries_json
    @countries_json ||= 'https://raw.githubusercontent.com/' \
      'everypolitician/everypolitician-data/master/countries.json'
  end

  def self.countries
    @countries ||= begin
      JSON.parse(open(countries_json).read, symbolize_names: true).map do |c|
        Country.new(c)
      end
    end
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

  class Country
    attr_reader :name
    attr_reader :code
    attr_reader :slug
    attr_reader :raw_data

    def self.find(query)
      query = { slug: query } if query.is_a?(String)
      country = Everypolitician.countries.find do |c|
        query.all? { |k, v| c[k].to_s.downcase == v.to_s.downcase }
      end
      fail Error, "Couldn't find country for query: #{query}" if country.nil?
      new(country)
    end

    def initialize(country_data)
      @name = country_data[:name]
      @code = country_data[:code]
      @slug = country_data[:slug]
      @raw_data = country_data
    end

    def [](key)
      raw_data[key]
    end

    def legislatures
      @legislatures ||= @raw_data[:legislatures].map { |l| Legislature.new(l, self) }
    end

    def legislature(query)
      query = { slug: query } if query.is_a?(String)
      legislature = legislatures.find do |l|
        query.all? { |k, v| l.__send__(k).to_s.downcase == v.to_s.downcase }
      end
      fail Error, "Unknown legislature: #{query}" if legislature.nil?
      legislature
    end
  end

  class Legislature
    attr_reader :name
    attr_reader :slug
    attr_reader :lastmod_str
    attr_reader :person_count
    attr_reader :sha
    attr_reader :country
    attr_reader :raw_data
    attr_reader :statement_count
    attr_reader :popolo_url

    def self.find(country_slug, legislature_slug)
      Country.find(country_slug).legislature(legislature_slug)
    end

    def initialize(legislature_data, country)
      @name = legislature_data[:name]
      @slug = legislature_data[:slug]
      @lastmod_str = legislature_data[:lastmod]
      @person_count = legislature_data[:person_count]
      @sha = legislature_data[:sha]
      @statement_count = legislature_data[:statement_count]
      @popolo_url = legislature_data[:popolo_url]
      @raw_data = legislature_data
      @country = country
    end

    def popolo
      @popolo ||= Everypolitician::Popolo.parse(open(popolo_url).read)
    end

    def legislative_periods
      @legislative_periods ||= raw_data[:legislative_periods].map do |lp|
        LegislativePeriod.new(lp, self, country)
      end
    end

    def directory
      @directory = raw_data[:sources_directory].split('/')[1, 2].join('/')
    end

    def self.from_sources_dir(dir)
      @index_by_sources ||= EveryPolitician.countries.map(&:legislatures).flatten.group_by(&:directory)
      @index_by_sources[dir][0]
    end

    def lastmod
      Time.at(lastmod_str.to_i).gmtime
    end
  end

  class LegislativePeriod
    attr_reader :id
    attr_reader :name
    attr_reader :slug
    attr_reader :legislature
    attr_reader :country
    attr_reader :raw_data

    def initialize(legislative_period_data, legislature, country)
      @id = legislative_period_data[:id]
      @name = legislative_period_data[:name]
      @slug = legislative_period_data[:slug]
      @legislature = legislature
      @country = country
      @raw_data = legislative_period_data
    end

    def start_date
      @start_date ||= parse_partial_date(raw_data[:start_date])
    end

    def end_date
      @end_date ||= parse_partial_date(raw_data[:end_date])
    end

    def csv_url
      @csv_url ||= 'https://raw.githubusercontent.com/everypolitician' \
        "/everypolitician-data/#{legislature.sha}/#{raw_data[:csv]}"
    end

    def csv
      CSV.parse(open(csv_url).read, headers: true, header_converters: :symbol, converters: nil)
    end

    def [](key)
      raw_data[key]
    end

    private

    def parse_partial_date(date)
      Date.new(*date.split('-').map(&:to_i))
    end
  end
end

# Alternative constant name which is how it's usually capitalized in public copy.
EveryPolitician ||= Everypolitician
