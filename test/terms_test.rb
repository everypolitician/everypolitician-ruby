require 'test_helper'

class EverypoliticianTest < Minitest::Test
  # Clear the countries.json cache before each run
  def setup
    Everypolitician.countries = nil
  end

  def test_legislative_periods
    VCR.use_cassette('countries_json') do
      au_senate = Everypolitician.country(slug: 'Australia').legislature(slug: 'Senate')
      lp = au_senate.legislative_periods.first
      assert_equal 'term/44', lp.id
      assert_equal '44th Parliament', lp.name
      assert_equal Date.new(2013, 9, 7), lp.start_date
      assert_equal '44', lp.slug
      assert %r{https://raw.githubusercontent.com/everypolitician/everypolitician-data/\w+?/data/Australia/Senate/term-44.csv}.match(lp.csv_url)
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
end
