require 'json'
require 'open-uri'

module Everypolitician
  class Index
    DEFAULT_INDEX_URL = 'https://raw.githubusercontent.com/' \
      'everypolitician/everypolitician-data/master/countries.json'.freeze

    attr_reader :index_url

    def initialize(index_url: DEFAULT_INDEX_URL)
      @index_url = index_url
    end

    def country(slug)
      country_index[slug.to_s.downcase]
    end

    def countries
      @countries ||= begin
        JSON.parse(open(index_url).read, symbolize_names: true).map do |c|
          Country.new(c)
        end
      end
    end

    private

    def country_index
      @country_index ||= Hash[countries.map { |c| [c.slug.downcase, c] }]
    end
  end
end
