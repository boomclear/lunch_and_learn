require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path('../fixtures/vcr_cassettes', __dir__)
  config.hook_into :webmock
  config.filter_sensitive_data('KEY') { ENV['KEY'] }
  # Filter both request URIs and response pagination links. Returning nil for
  # an unset/empty key avoids replacing every empty string in a cassette.
  config.filter_sensitive_data('<UNSPLASH_ACCESS_KEY>') do
    key = ENV['unsplash_key']
    key unless key.nil? || key.empty?
  end
  config.default_cassette_options = { re_record_interval: 7 * 24 * 60 * 60 }
  config.configure_rspec_metadata!
end
