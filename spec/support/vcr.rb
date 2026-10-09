require 'vcr'

# Only credential parameters for these hosts are ignored during matching.
# Country queries, paths, and parameters on other hosts still have to match.
provider_credentials = {
  'api.unsplash.com' => { 'client_id' => ['unsplash_key', '<UNSPLASH_ACCESS_KEY>'] },
  'youtube.googleapis.com' => { 'key' => ['google_api', '<GOOGLE_API_KEY>'] },
  'www.googleapis.com' => { 'key' => ['google_api', '<GOOGLE_API_KEY>'] },
  'api.edamam.com' => {
    'app_id' => ['edamam_id', '<EDAMAM_APPLICATION_ID>'],
    'app_key' => ['edamam_key', '<EDAMAM_API_KEY>']
  }
}

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path('../fixtures/vcr_cassettes', __dir__)
  config.hook_into :webmock
  config.filter_sensitive_data('KEY') { ENV['KEY'] }
  provider_credentials.values.flat_map(&:values).uniq.each do |env_name, placeholder|
    # VCR filters requests, response links, headers, and bodies. Nil prevents
    # empty environment values from replacing every empty string in a cassette.
    config.filter_sensitive_data(placeholder) do
      value = ENV[env_name]
      value unless value.nil? || value.empty?
    end
  end

  # A normalized/escaped URI can differ from the environment value. Also
  # redact provider query values directly, including when ENV is absent.
  config.before_record do |interaction|
    parameters = provider_credentials[interaction.request.parsed_uri.host]
    next unless parameters

    query = interaction.request.uri.split('?', 2).last if interaction.request.uri.include?('?')
    query.to_s.split('#', 2).first.to_s.split('&').each do |pair|
      name, value = pair.split('=', 2)
      begin
        name = URI.decode_www_form_component(name)
      rescue ArgumentError
        next
      end
      next unless parameters.key?(name) && value && !value.empty?

      placeholder = parameters.fetch(name).last
      interaction.filter!(value, placeholder)
      begin
        decoded = URI.decode_www_form_component(value)
      rescue ArgumentError
        decoded = nil # A legacy URI may contain a literal, unescaped percent.
      end
      if decoded && decoded.valid_encoding? && !decoded.empty? && decoded != value
        interaction.filter!(decoded, placeholder)
      end
    end
  end

  config.register_request_matcher(:uri_without_provider_credentials) do |first, second|
    host = first.parsed_uri.host
    parameters = provider_credentials[host]
    if parameters && host == second.parsed_uri.host
      without_credentials = lambda do |request|
        uri = request.parsed_uri
        pairs = uri.query.to_s.split('&').reject do |pair|
          begin
            parameters.key?(URI.decode_www_form_component(pair.split('=', 2).first))
          rescue ArgumentError
            false
          end
        end
        uri.query = pairs.empty? ? nil : pairs.join('&')
        uri
      end
      without_credentials.call(first) == without_credentials.call(second)
    else
      VCR.request_matchers[:uri].matches?(first, second)
    end
  end
  config.default_cassette_options = {
    re_record_interval: 7 * 24 * 60 * 60,
    match_requests_on: [:method, :uri_without_provider_credentials]
  }
  config.configure_rspec_metadata!
end
