require 'test_helper'

CDN = 'https://cdn.rawgit.com'.freeze

class EverypoliticianTest < Minitest::Test
  # Clear the countries.json cache before each run
  def setup
    Everypolitician.countries = nil
  end

  def test_legislature_find
    VCR.use_cassette('countries_json') do
      legislature = Everypolitician::Legislature.find('Australia', 'Senate')
      assert_equal 'Senate', legislature.name
      assert %r{#{CDN}/everypolitician/everypolitician-data/\w+?/data/Australia/Senate/ep-popolo-v1.0.json}.match(legislature.popolo_url)
      assert legislature.legislative_periods.is_a?(Array)
    end
  end

  def test_legislature_find_returns_nil_for_missing_legislatures
    VCR.use_cassette('countries_json') do
      assert_nil Everypolitician::Legislature.find('Narnia', 'Aslan')
    end
  end

  def test_legislature_find_returns_nil_for_known_country_unknown_legislature
    VCR.use_cassette('countries_json') do
      assert_nil Everypolitician::Legislature.find('Australia', 'ThisIsNotAHouse')
    end
  end

  def test_find_legislature_is_case_insensitive
    VCR.use_cassette('countries_json') do
      legislature = Everypolitician::Legislature.find('UK', 'commons')
      assert_equal 'House of Commons', legislature.name
    end
  end

  def test_legislature_convenience_method
    VCR.use_cassette('countries_json') do
      legislature = Everypolitician.legislature('Australia', 'Senate')
      assert_equal 'Senate', legislature.name
      assert %r{#{CDN}/everypolitician/everypolitician-data/\w+?/data/Australia/Senate/ep-popolo-v1.0.json}.match(legislature.popolo_url)
      assert legislature.legislative_periods.is_a?(Array)
    end
  end

  def test_sources_dir_convenience_method
    VCR.use_cassette('countries_json') do
      legislature = Everypolitician::Legislature.from_sources_dir('Australia/Senate')
      assert_equal 'Australia', legislature.country.name
      assert_equal 'AU', legislature.country.code
      assert_equal 'Senate', legislature.name
    end
  end

  def test_finding_legislature_by_attributes
    VCR.use_cassette('countries_json') do
      country = Everypolitician.country(code: 'AU')
      senate = country.legislature(slug: 'Senate')
      assert_equal 'Senate', senate.name
    end
  end

  def test_accessing_properties_with_square_brackets
    VCR.use_cassette('countries_json') do
      legislature = Everypolitician::Legislature.find('UK', 'commons')
      assert_equal 'House of Commons', legislature[:name]
    end
  end

  def test_csv_url_method
    VCR.use_cassette('countries_json') do
      legislature = Everypolitician::Legislature.find('UK', 'commons')
      base = 'https://cdn.rawgit.com/everypolitician/everypolitician-data/'
      sha = legislature.sha
      path = '/data/UK/Commons/names.csv'
      assert_equal legislature.names_url, URI.join(base, sha + path).to_s
    end
  end

  def test_upper_house_method
    VCR.use_cassette('countries_json') do
      bicameral = Everypolitician.country(code: 'CM')
      assert_equal 'Sénat', bicameral.upper_house.name
      unicameral = Everypolitician.country(code: 'GG-ALD')
      assert_equal 'States', unicameral.upper_house.name
    end
  end

  def test_lower_house_method
    VCR.use_cassette('countries_json') do
      bicameral = Everypolitician.country(code: 'CM')
      assert_equal 'Assemblée Nationale', bicameral.lower_house.name
      unicameral = Everypolitician.country(code: 'GG-ALD')
      assert_equal 'States', unicameral.lower_house.name
      two_lower_houses = Everypolitician.country(code: 'VG')
      assert_equal 'House of Assembly', two_lower_houses.lower_house.name
    end
  end
end
