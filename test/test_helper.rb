$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'everypolitician'

require 'minitest/autorun'
require 'minitest/around/unit'
require 'vcr'
require 'pry'

CDN = 'https://cdn.rawgit.com'.freeze

VCR.configure do |config|
  config.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  config.hook_into :webmock
end
