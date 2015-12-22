require 'test_helper'

class EverypoliticianTest < Minitest::Test
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

  def test_legislature_find
    VCR.use_cassette('countries_json') do
      legislature = Everypolitician::Legislature.find('Australia', 'Senate')
      assert_equal 'Senate', legislature.name
      assert_equal 'data/Australia/Senate/sources', legislature.sources_directory
      assert_equal 'data/Australia/Senate/ep-popolo-v1.0.json', legislature.popolo
      assert_equal 'data/Australia/Senate/names.csv', legislature.names
      assert legislature.legislative_periods.is_a?(Array)
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

  def test_legislature_convenience_method
    VCR.use_cassette('countries_json') do
      legislature = Everypolitician.legislature('Australia', 'Senate')
      assert_equal 'Senate', legislature.name
      assert_equal 'data/Australia/Senate/sources', legislature.sources_directory
      assert_equal 'data/Australia/Senate/ep-popolo-v1.0.json', legislature.popolo
      assert_equal 'data/Australia/Senate/names.csv', legislature.names
      assert legislature.legislative_periods.is_a?(Array)
    end
  end

  def test_country_and_legislature_convenience_method
    VCR.use_cassette('countries_json') do
      country, legislature = Everypolitician.country_legislature('Australia', 'Senate')
      assert_equal 'Australia', country.name
      assert_equal 'AU', country.code
      assert_equal 2, country.legislatures.size
      assert_equal 'Senate', legislature.name
      assert_equal 'data/Australia/Senate/sources', legislature.sources_directory
      assert_equal 'data/Australia/Senate/ep-popolo-v1.0.json', legislature.popolo
      assert_equal 'data/Australia/Senate/names.csv', legislature.names
      assert legislature.legislative_periods.is_a?(Array)
    end
  end

  def test_raises_an_error_for_unknown_slugs
    VCR.use_cassette('countries_json') do
      assert_raises Everypolitician::Error do
        Everypolitician.country('Foo')
      end
    end
    VCR.use_cassette('countries_json') do
      assert_raises Everypolitician::Error do
        Everypolitician.legislature('Foo', 'Bar')
      end
    end
  end

  def test_retrieving_countries_json
    VCR.use_cassette('countries_json') do
      countries_json = Everypolitician::CountriesJson.new
      assert_equal countries_json.countries_json_url, 'https://raw.githubusercontent.com/' \
        'everypolitician/everypolitician-data/master/countries.json'
    end
  end

  def test_alternative_constant_name
    assert_equal Everypolitician, EveryPolitician
  end
end
