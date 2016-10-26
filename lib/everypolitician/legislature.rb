require 'open-uri'
require 'everypolitician/popolo'

module Everypolitician
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
    attr_reader :type

    def self.find(country_slug, legislature_slug)
      country = Country.find(country_slug)
      country && country.legislature(legislature_slug)
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
      @type = legislature_data[:type]
    end

    def [](key)
      raw_data[key]
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

    def latest_term
      @latest_term ||= popolo.terms.find_by(id: legislative_periods.max_by(&:start_date).id)
    end

    def self.from_sources_dir(dir)
      @index_by_sources ||= EveryPolitician.countries.map(&:legislatures).flatten.group_by(&:directory)
      @index_by_sources[dir][0]
    end

    def lastmod
      Time.at(lastmod_str.to_i).gmtime
    end

    def names_url
      'https://cdn.rawgit.com/everypolitician/everypolitician-data/%s/%s' %
        [sha, raw_data[:names]]
    end
  end
end
