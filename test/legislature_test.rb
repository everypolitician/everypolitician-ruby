# frozen_string_literal: true

require 'test_helper'

class EverypoliticianLegislatureTest < Minitest::Test
  # Clear the countries.json cache before each run
  def setup
    Everypolitician.countries = nil
  end

  def around(&block)
    VCR.use_cassette('countries_json') do
      block.call
    end
  end

  def test_legislature_find
    legislature = Everypolitician::Legislature.find('Australia', 'Senate')
    assert_equal 'Senate', legislature.name
    assert %r{#{CDN}/everypolitician/everypolitician-data/\w+?/data/Australia/Senate/ep-popolo-v1.0.json}.match(legislature.popolo_url)
    assert legislature.legislative_periods.is_a?(Array)
  end

  def test_legislature_find_returns_nil_for_missing_legislatures
    assert_nil Everypolitician::Legislature.find('Narnia', 'Aslan')
  end

  def test_legislature_find_returns_nil_for_known_country_unknown_legislature
    assert_nil Everypolitician::Legislature.find('Australia', 'ThisIsNotAHouse')
  end

  def test_find_legislature_is_case_insensitive
    legislature = Everypolitician::Legislature.find('UK', 'commons')
    assert_equal 'House of Commons', legislature.name
  end

  def test_legislature_convenience_method
    legislature = Everypolitician.legislature('Australia', 'Senate')
    assert_equal 'Senate', legislature.name
    assert %r{#{CDN}/everypolitician/everypolitician-data/\w+?/data/Australia/Senate/ep-popolo-v1.0.json}.match(legislature.popolo_url)
    assert legislature.legislative_periods.is_a?(Array)
  end

  def test_sources_dir_convenience_method
    legislature = Everypolitician::Legislature.from_sources_dir('Australia/Senate')
    assert_equal 'Australia', legislature.country.name
    assert_equal 'AU', legislature.country.code
    assert_equal 'Senate', legislature.name
  end

  def test_finding_legislature_by_attributes
    country = Everypolitician.country(code: 'AU')
    senate = country.legislature(slug: 'Senate')
    assert_equal 'Senate', senate.name
  end

  def test_accessing_properties_with_square_brackets
    legislature = Everypolitician::Legislature.find('UK', 'commons')
    assert_equal 'House of Commons', legislature[:name]
  end

  def test_csv_url_method
    legislature = Everypolitician::Legislature.find('UK', 'commons')
    base = 'https://cdn.rawgit.com/everypolitician/everypolitician-data/'
    sha = legislature.sha
    path = '/data/UK/Commons/names.csv'
    assert_equal legislature.names_url, URI.join(base, sha + path).to_s
  end

  def test_upper_house_method
    bicameral = Everypolitician.country(code: 'CM')
    assert_equal 'Sénat', bicameral.upper_house.name
  end

  def test_upper_house_with_missing_upper_house
    bicameral = Everypolitician.country(code: 'UK')
    assert_equal nil, bicameral.upper_house
  end

  def test_upper_house_with_unicameral_house
    unicameral = Everypolitician.country(code: 'GG-ALD')
    assert_equal 'States', unicameral.upper_house.name
  end

  def test_lower_house_method
    bicameral = Everypolitician.country(code: 'CM')
    assert_equal 'Assemblée Nationale', bicameral.lower_house.name
  end

  def test_lower_house_with_unicameral_house
    unicameral = Everypolitician.country(code: 'GG-ALD')
    assert_equal 'States', unicameral.lower_house.name
  end

  def test_lower_house_returns_most_recent_house
    two_houses = Everypolitician.country(code: 'VG')
    assert_equal 'House of Assembly', two_houses.lower_house.name
  end

  def test_upper_house_returns_most_recent_house
    two_houses = Everypolitician.country(code: 'VG')
    assert_equal 'House of Assembly', two_houses.upper_house.name
  end
end
