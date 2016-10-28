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
      assert_equal 'term/45', term.id
      assert_equal '45th Parliament', term.name
      assert_equal Date.new(2016, 7, 2), term.start_date
      assert_equal '45', term.slug
      assert_equal 'Senate', term.legislature.name
      assert_equal 'Australia', term.country.name
    end
  end

  def test_legislative_period_csv_url
    VCR.use_cassette('countries_json') do
      au_senate = Everypolitician.country(slug: 'Australia').legislature(slug: 'Senate')
      term = au_senate.legislative_periods.first
      assert_includes term.csv_url, 'https://cdn.rawgit.com/everypolitician/everypolitician-data/'
      assert_includes term.csv_url, '/data/Australia/Senate/term-45.csv'
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
      assert_equal 'term/45', term[:id]
      assert_equal '45th Parliament', term[:name]
      assert_equal '2016-07-02', term[:start_date]
      assert_equal 'data/Australia/Senate/term-45.csv', term[:csv]
    end
  end

  def test_legislative_period_end_date
    VCR.use_cassette('countries_json') do
      term = Everypolitician.country(slug: 'Australia').legislature(slug: 'Representatives').legislative_periods[1]
      assert_equal Date.new(2016, 5, 9), term.end_date
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

  def test_latest_term
    VCR.use_cassette('albania_term', record: :once) do
      af = Everypolitician.country(slug: 'Albania').legislature(slug: 'Assembly')
      term = af.latest_term
      assert_instance_of EveryPolitician::Popolo::LegislativePeriod, term
      assert_equal term.id, 'term/8'
      assert_equal term.memberships.count, 139
    end
  end
end
