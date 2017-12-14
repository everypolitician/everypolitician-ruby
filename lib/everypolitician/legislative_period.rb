# frozen_string_literal: true

require 'open-uri'
require 'csv'

module Everypolitician
  class LegislativePeriod
    attr_reader :id
    attr_reader :name
    attr_reader :slug
    attr_reader :legislature
    attr_reader :country
    attr_reader :raw_data
    attr_reader :csv_url

    def initialize(legislative_period_data, legislature, country)
      @id = legislative_period_data[:id]
      @name = legislative_period_data[:name]
      @slug = legislative_period_data[:slug]
      @csv_url = legislative_period_data[:csv_url]
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

    def csv
      CSV.parse(open(csv_url).read, headers: true, header_converters: :symbol, converters: nil)
    end

    def [](key)
      raw_data[key]
    end

    private

    def parse_partial_date(date)
      return if date.to_s.empty?
      Date.new(*date.split('-').map(&:to_i))
    end
  end
end
