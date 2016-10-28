require 'test_helper'

class EverypoliticianTest < Minitest::Test
  # Clear the countries.json cache before each run
  def setup
    Everypolitician.countries = nil
  end

  def test_that_it_has_a_version_number
    refute_nil ::Everypolitician::VERSION
  end

  def test_country_find
    VCR.use_cassette('countries_json') do
      country = Everypolitician::Country.find('Australia')
      assert_equal 'Australia', country.name
      assert_equal 'AU', country.code
      assert_equal 2, country.legislatures.size
    end
  end

  def test_country_find_returns_nil_for_missing_countries
    VCR.use_cassette('countries_json') do
      assert_nil Everypolitician::Country.find('Narnia')
    end
  end

  def test_finds_country_by_hash_pair
    VCR.use_cassette('countries_json') do
      country = Everypolitician::Country.find(slug: 'Australia')
      assert_equal 'Australia', country.name
    end
  end

  def test_find_country_is_case_insensitive
    VCR.use_cassette('countries_json') do
      country = Everypolitician::Country.find('new-zealand')
      assert_equal 'New Zealand', country.name
    end
  end

  def test_country_convenience_method
    VCR.use_cassette('countries_json') do
      country = Everypolitician.country('Australia')
      assert_equal 'Australia', country.name
      assert_equal 'AU', country.code
      assert_equal 2, country.legislatures.size
    end
  end

  def test_country_and_legislature_convenience_method
    VCR.use_cassette('countries_json') do
      country, legislature = Everypolitician.country_legislature('Australia', 'Senate')
      assert_equal 'Australia', country.name
      assert_equal 'AU', country.code
      assert_equal 2, country.legislatures.size
      assert_equal 'Senate', legislature.name
      assert %r{#{CDN}/everypolitician/everypolitician-data/\w+?/data/Australia/Senate/ep-popolo-v1.0.json}.match(legislature.popolo_url)
      assert_equal 'Australia/Senate', legislature.directory
      assert legislature.legislative_periods.is_a?(Array)
    end
  end

  def test_retrieving_countries_json
    VCR.use_cassette('countries_json') do
      assert_equal Everypolitician.countries_json, 'https://raw.githubusercontent.com/' \
        'everypolitician/everypolitician-data/master/countries.json'
    end
  end

  def test_setting_countries_json_url
    Everypolitician.countries_json = 'path/to/local/countries.json'
    assert_equal 'path/to/local/countries.json', Everypolitician.countries_json
    Everypolitician.countries_json = nil
  end

  def test_alternative_constant_name
    assert_equal Everypolitician, EveryPolitician
  end

  def test_retrieving_popolo
    VCR.use_cassette('popolo', record: :new_episodes) do
      australia_senate = Everypolitician.legislature('Australia', 'Senate')
      assert_instance_of Everypolitician::Popolo::JSON, australia_senate.popolo
    end
  end

  def test_getting_all_countries
    VCR.use_cassette('countries_json') do
      all_countries = Everypolitician.countries
      assert_equal 233, all_countries.size
      country = all_countries.first
      assert_instance_of Everypolitician::Country, country
    end
  end

  def test_finding_country_by_attributes
    VCR.use_cassette('countries_json') do
      country = Everypolitician.country(code: 'AU')
      assert_equal 'Australia', country.name
    end
  end

  def test_accessing_properties_with_square_brackets
    VCR.use_cassette('countries_json') do
      country = Everypolitician.country(code: 'AU')
      assert_equal 'Australia', country[:name]
    end
  end

  def test_expose_the_statement_count_of_a_legislature
    VCR.use_cassette('countries_json') do
      uganda_parliament = Everypolitician.country(slug: 'Uganda').legislature(slug: 'Parliament')
      assert_equal 18_921, uganda_parliament.statement_count
    end
  end

  def test_lastmod_is_a_time
    legislature = Everypolitician::Legislature.new({ lastmod: '1469382925' }, nil)
    assert_equal 2016, legislature.lastmod.year
    assert_equal 7, legislature.lastmod.month
    assert_equal   24, legislature.lastmod.day
    assert_equal   17, legislature.lastmod.hour
  end
end
