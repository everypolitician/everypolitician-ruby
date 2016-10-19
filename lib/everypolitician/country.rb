module Everypolitician
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
      return if country.nil?
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
      legislatures.find do |l|
        query.all? { |k, v| l.__send__(k).to_s.downcase == v.to_s.downcase }
      end
    end

    def upper_house
      @upper_house ||= get_house('upper house')
    end

    def lower_house
      @lower_house ||= get_house('lower house')
    end

    private

    def get_house(type)
      houses = legislatures.select { |l| l.type == type || l.type == 'unicameral legislature' }
      return houses.first if houses.count == 1
      houses.sort_by { |h| h.legislative_periods.max_by { |l| l[:start_date] }[:start_date] }.last
    end
  end
end
