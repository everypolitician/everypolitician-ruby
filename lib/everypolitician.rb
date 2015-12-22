require 'everypolitician/version'
require 'json'
require 'open-uri'

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

  class Entity
    def initialize(data)
      data.each do |key, value|
        define_singleton_method(key) do
          value
        end
      end
    end
  end

  class Country < Entity
    def self.find(slug)
      country = CountriesJson.new.find { |c| c[:slug] == slug }
      fail Error, "Unknown country slug: #{slug}" if country.nil?
      new(country)
    end

    def legislature(slug)
      legislature = legislatures.find { |l| l[:slug] == slug }
      fail Error, "Unknown legislature slug: #{slug}" if legislature.nil?
      Legislature.new(legislature)
    end
  end

  class Legislature < Entity
    def self.find(country_slug, legislature_slug)
      Country.find(country_slug).legislature(legislature_slug)
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
