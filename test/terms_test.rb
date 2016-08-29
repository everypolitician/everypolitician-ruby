require 'test_helper'

class EverypoliticianTest < Minitest::Test
  # Clear the countries.json cache before each run
  def setup
    Everypolitician.countries = nil
  end

  def test_legislative_periods
    VCR.use_cassette('countries_json') do
      au_senate = Everypolitician.country(slug: 'Australia').legislature(slug: 'Senate')
      term = au_senate.legislative_periods.first
      assert_equal 'term/44', term.id
      assert_equal '44th Parliament', term.name
      assert_equal Date.new(2013, 9, 7), term.start_date
      assert_equal '44', term.slug
      assert_equal 'Senate', term.legislature.name
      assert_equal 'Australia', term.country.name
    end
  end

  def test_legislative_period_csv_url
    VCR.use_cassette('countries_json') do
      au_senate = Everypolitician.country(slug: 'Australia').legislature(slug: 'Senate')
      term = au_senate.legislative_periods.first
      assert_includes term.csv_url, 'https://cdn.rawgit.com/everypolitician/everypolitician-data/'
      assert_includes term.csv_url, '/data/Australia/Senate/term-44.csv'
    end
  end

  def test_legislative_period_csv
    VCR.use_cassette('term-44-csv') do
      au_senate = Everypolitician.country(slug: 'Australia').legislature(slug: 'Senate')
      term = au_senate.legislative_periods.first
      csv = term.csv
      assert_instance_of CSV::Table, csv
    end
  end

  def test_legislative_period_square_brackets_expose_raw_data
    VCR.use_cassette('countries_json') do
      au_senate = Everypolitician.country(slug: 'Australia').legislature(slug: 'Senate')
      term = au_senate.legislative_periods.first
      assert_equal 'term/44', term[:id]
      assert_equal '44th Parliament', term[:name]
      assert_equal '2013-09-07', term[:start_date]
      assert_equal 'data/Australia/Senate/term-44.csv', term[:csv]
    end
  end

  def test_legislative_period_end_date
    VCR.use_cassette('countries_json') do
      term = Everypolitician.country(slug: 'Australia').legislature(slug: 'Representatives').legislative_periods[1]
      assert_equal Date.new(2013, 9, 7), term.end_date
    end
  end

  def test_missing_legislative_period_end_date
    VCR.use_cassette('countries_json') do
      term = Everypolitician.country(slug: 'Australia').legislature(slug: 'Representatives').legislative_periods.first
      assert_nil term.end_date
    end
  end

  def test_partial_dates
    VCR.use_cassette('countries_json') do
      af = Everypolitician.country(slug: 'Albania').legislature(slug: 'Assembly')
      term = af.legislative_periods.last
      assert_equal Date.new(2009), term.start_date
      assert_equal Date.new(2013), term.end_date
    end
  end
end
