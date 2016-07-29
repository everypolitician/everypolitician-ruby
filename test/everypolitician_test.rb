require 'test_helper'

class EverypoliticianTest < Minitest::Test

  # Clear the countries.json cache before each run
  def setup
    Everypolitician.countries = nil
    @current_sha = 'ea04acd'
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

  def test_legislature_find
    VCR.use_cassette('countries_json') do
      legislature = Everypolitician::Legislature.find('Australia', 'Senate')
      assert_equal 'Senate', legislature.name
      assert_equal "https://raw.githubusercontent.com/everypolitician/everypolitician-data/#{@current_sha}/data/Australia/Senate/ep-popolo-v1.0.json", legislature.popolo_url
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
      assert_equal "https://raw.githubusercontent.com/everypolitician/everypolitician-data/#{@current_sha}/data/Australia/Senate/ep-popolo-v1.0.json", legislature.popolo_url
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
      assert_equal "https://raw.githubusercontent.com/everypolitician/everypolitician-data/#{@current_sha}/data/Australia/Senate/ep-popolo-v1.0.json", legislature.popolo_url
      assert_equal 'Australia/Senate', legislature.directory
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
    VCR.use_cassette('popolo') do
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

  def test_finding_legislature_by_attributes
    VCR.use_cassette('countries_json') do
      country = Everypolitician.country(code: 'AU')
      senate = country.legislature(slug: 'Senate')
      assert_equal 'Senate', senate.name
    end
  end

  def test_accessing_properties_with_square_brackets
    VCR.use_cassette('countries_json') do
      country = Everypolitician.country(code: 'AU')
      assert_equal 'Australia', country[:name]
    end
  end

  def test_legislative_periods
    VCR.use_cassette('countries_json') do
      au_senate = Everypolitician.country(slug: 'Australia').legislature(slug: 'Senate')
      lp = au_senate.legislative_periods.first
      assert_equal 'term/44', lp.id
      assert_equal '44th Parliament', lp.name
      assert_equal Date.new(2013, 9, 7), lp.start_date
      assert_equal '44', lp.slug
      assert_equal "https://raw.githubusercontent.com/everypolitician/everypolitician-data/#{@current_sha}/data/Australia/Senate/term-44.csv", lp.csv_url
      assert_equal 'Senate', lp.legislature.name
      assert_equal 'Australia', lp.country.name
    end
  end

  def test_legislative_period_csv
    VCR.use_cassette('term-44-csv') do
      au_senate = Everypolitician.country(slug: 'Australia').legislature(slug: 'Senate')
      lp = au_senate.legislative_periods.first
      csv = lp.csv
      assert_instance_of CSV::Table, csv
    end
  end

  def test_legislative_period_square_brackets_expose_raw_data
    VCR.use_cassette('countries_json') do
      au_senate = Everypolitician.country(slug: 'Australia').legislature(slug: 'Senate')
      lp = au_senate.legislative_periods.first
      assert_equal 'term/44', lp[:id]
      assert_equal '44th Parliament', lp[:name]
      assert_equal '2013-09-07', lp[:start_date]
      assert_equal 'data/Australia/Senate/term-44.csv', lp[:csv]
    end
  end

  def test_legislative_period_end_date
    VCR.use_cassette('countries_json') do
      lp = Everypolitician.country(slug: 'Australia').legislature(slug: 'Representatives').legislative_periods[1]
      assert_equal Date.new(2013, 9, 7), lp.end_date
    end
  end

  def test_partial_dates
    VCR.use_cassette('countries_json') do
      af = Everypolitician.country(slug: 'Albania').legislature(slug: 'Assembly')
      lp = af.legislative_periods.last
      assert_equal Date.new(2009), lp.start_date
      assert_equal Date.new(2013), lp.end_date
    end
  end

  def test_expose_the_statement_count_of_a_legislature
    VCR.use_cassette('countries_json') do
      uganda_parliament = Everypolitician.country(slug: 'Uganda').legislature(slug: 'Parliament')
      assert_equal 18031, uganda_parliament.statement_count
    end
  end

  def test_legislative_period_uses_name_when_interpolated
    VCR.use_cassette('countries_json') do
      au_first_legislative_period = Everypolitician
        .country('Australia')
        .legislature('Representatives')
        .legislative_periods[1]
      assert_equal 'Fetching data for 43rd Parliament', "Fetching data for #{au_first_legislative_period}"
    end
  end

end
