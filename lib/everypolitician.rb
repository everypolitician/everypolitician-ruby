require 'everypolitician/version'
require 'json'
require 'open-uri'

module Everypolitician
  class Error < StandardError; end

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
    def self.find(slug)
      countries = JSON.parse(open('https://raw.githubusercontent.com/everypolitician/everypolitician-data/master/countries.json').read, symbolize_names: true)
      country = countries.find { |country| country[:slug] == slug }
      raise Error, "Unknown country slug: #{slug}" if country.nil?
      new(country)
    end

    def initialize(country_data)
      country_data.each do |key, value|
        define_singleton_method(key) do
          value
        end
      end
    end

    def legislature(slug)
      legislature = legislatures.find { |legislature| legislature[:slug] == slug }
      raise Error, "Unknown legislature slug: #{slug}" if legislature.nil?
      Legislature.new(legislature)
    end
  end

  class Legislature
    def self.find(country_slug, legislature_slug)
      Country.find(country_slug).legislature(legislature_slug)
    end

    def initialize(legislature_data)
      legislature_data.each do |key, value|
        define_singleton_method(key) do
          value
        end
      end
    end
  end
end
