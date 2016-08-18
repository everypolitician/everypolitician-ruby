require 'test_helper'

class EverypoliticianIndexTest < Minitest::Test
  def test_country
    VCR.use_cassette('countries_json') do
      index = Everypolitician::Index.new
      australia = index.country('Australia')
      assert_equal 'Australia', australia.name
      assert_equal 'AU', australia.code
      assert_equal 2, australia.legislatures.size
    end
  end

  def test_country_with_sha
    VCR.use_cassette('countries_json@bc95a4a') do
      index = Everypolitician::Index.new('bc95a4a')
      sweden = index.country('Sweden')
      assert_equal 96_236, sweden.legislature('Riksdag').statement_count
    end
  end
end
