# frozen_string_literal: true

require 'everypolitician/version'
require 'json'
require 'open-uri'
require 'require_all'

require_rel 'everypolitician'

module Everypolitician
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
end
