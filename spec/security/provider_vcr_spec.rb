require 'spec_helper'
require 'tmpdir'
require 'yaml'
require 'json'
require 'net/http'
require 'uri'
require 'open3'
require 'webmock/rspec'
require 'faraday'
require_relative '../support/vcr'
require_relative '../../app/services/youtube_service'
require_relative '../../app/services/unsplash_service'
require_relative '../../app/services/edamam_service'
require_relative '../../app/facades/learning_resources_facade'
require_relative '../../app/facades/edamam_facade'
require_relative '../../app/poros/learning_resource'
require_relative '../../app/poros/recipe'

RSpec.describe 'Provider cassette credential protection' do
  around do |example|
    names = %w[google_api edamam_id edamam_key unsplash_key]
    original_values = names.to_h { |name| [name, ENV[name]] }
    original_library = VCR.configuration.cassette_library_dir
    WebMock.disable_net_connect!
    Dir.mktmpdir('provider-vcr') do |directory|
      VCR.configure { |config| config.cassette_library_dir = directory }
      example.run
    end
  ensure
    original_values.each { |name, value| ENV[name] = value }
    VCR.configure { |config| config.cassette_library_dir = original_library }
  end

  def record_response(uri, values)
    interaction = VCR::HTTPInteraction.new(
      VCR::Request.new(:get, uri, nil, {}),
      VCR::Response.new(VCR::ResponseStatus.new(200, 'OK'),
        { 'Content-Type' => ['application/json'], 'Link' => ["<#{uri}&page=2>; rel=\"next\""],
          'X-Test-Credentials' => [values.join(',')] },
        JSON.generate(results: values), '1.1')
    )
    VCR.use_cassette('provider', record: :all) { VCR.record_http_interaction(interaction) }
    File.read(File.join(VCR.configuration.cassette_library_dir, 'provider.yml'))
  end

  def unredacted_provider_parameters?(text)
    redacted = text.gsub(/<(?:UNSPLASH_ACCESS_KEY|GOOGLE_API_KEY|EDAMAM_APPLICATION_ID|EDAMAM_API_KEY)>/, 'REDACTED')
    redacted = redacted.gsub(/%3C(?:UNSPLASH_ACCESS_KEY|GOOGLE_API_KEY|EDAMAM_APPLICATION_ID|EDAMAM_API_KEY)%3E/i, 'REDACTED')
    redacted.scan(/[?&]([^=&#\s]+)=([^&\s'"\\]+)/).any? do |name, value|
      begin
        parameter = URI.decode_www_form_component(name)
      rescue ArgumentError
        next false
      end
      next false unless %w[client_id key app_id app_key api_key apikey api-key access_token refresh_token client_secret token password secret authorization auth].include?(parameter.downcase)

      begin
        decoded = URI.decode_www_form_component(value).strip.delete_prefix('%')
        !decoded.match?(/\A(?:REDACTED|<[A-Z][A-Z0-9_]*>)[>;]*\z/)
      rescue ArgumentError
        true # Never print the exception: it can contain the rejected value.
      end
    end
  end

  def unredacted_fixture_bodies_or_headers?(text)
    placeholder = /\A(?:(?:Bearer|Basic) )?<[^>]+>\z/i
    sensitive_name = /\A(?:api[_-]?key|access[_-]?token|refresh[_-]?token|client[_-]?secret|secret|password|token)\z/i
    sensitive_json = lambda do |value|
      case value
      when Hash
        value.any? do |name, child|
          (name.match?(sensitive_name) && child.is_a?(String) && !child.empty? && !child.match?(placeholder)) || sensitive_json.call(child)
        end
      when Array
        value.any? { |child| sensitive_json.call(child) }
      else
        false
      end
    end
    fixture = YAML.safe_load(text)
    return true unless fixture.is_a?(Hash) && fixture['http_interactions'].is_a?(Array)
    fixture.fetch('http_interactions').any? do |interaction|
      return true unless interaction.is_a?(Hash)
      %w[request response].any? do |side|
        part = interaction.fetch(side)
        return true unless part.is_a?(Hash) && part.fetch('headers', {}).is_a?(Hash) && part['body'].is_a?(Hash)
        header_violation = part.fetch('headers', {}).any? do |name, values|
          next false unless name.match?(/\A(?:authorization|proxy-authorization|x-api-key|x-goog-api-key)\z/i)
          Array(values).any? { |value| !value.empty? && !value.match?(placeholder) }
        end
        body_violation = begin
          sensitive_json.call(JSON.parse(part.fetch('body').fetch('string').to_s))
        rescue JSON::ParserError
          false
        end
        header_violation || body_violation
      end
    end
  rescue Psych::Exception, KeyError, TypeError, NoMethodError
    true # Parser/type errors can quote data; report only the fixture filename.
  end

  {
    'Google/YouTube' => ['https://youtube.googleapis.com/youtube/v3/search',
      { 'key' => ['google_api', '<GOOGLE_API_KEY>'] }],
    'Edamam' => ['https://api.edamam.com/api/recipes/v2',
      { 'app_id' => ['edamam_id', '<EDAMAM_APPLICATION_ID>'],
        'app_key' => ['edamam_key', '<EDAMAM_API_KEY>'] }]
  }.each do |provider, (url, credentials)|
    it "redacts #{provider} requests, links, headers and bodies and replays with new dummy credentials" do
      parameters = { 'q' => 'laos' }
      credentials.each { |parameter, (env_name, _)| parameters[parameter] = ENV[env_name] = "dummy-record-#{env_name}" }
      cassette = record_response("#{url}?#{URI.encode_www_form(parameters)}", parameters.values.drop(1))
      credentials.each_value do |env_name, placeholder|
        expect(cassette.include?(ENV.fetch(env_name))).to be(false)
        expect(cassette).to include(placeholder)
      end
      credentials.each { |parameter, (env_name, _)| parameters[parameter] = ENV[env_name] = "dummy-replay-#{env_name}" }
      VCR.use_cassette('provider', record: :none, re_record_interval: nil) do
        response = Net::HTTP.get_response(URI("#{url}?#{URI.encode_www_form(parameters)}"))
        expect(response.code).to eq('200')
        expect(JSON.parse(response.body).fetch('results')).to eq(parameters.values.drop(1))
        credentials.each_key { |name| expect(response['Link']).to include(parameters.fetch(name)) }
      end
      VCR.use_cassette('provider', record: :none, re_record_interval: nil) do
        changed_query = parameters.merge('q' => 'peru')
        expect { Net::HTTP.get_response(URI("#{url}?#{URI.encode_www_form(changed_query)}")) }
          .to raise_error(VCR::Errors::UnhandledHTTPRequestError)
      end
    end

    [nil, ''].each do |empty_value|
      it "handles #{provider} #{empty_value.nil? ? 'unset' : 'empty'} environment values without corrupting content" do
        credentials.each_value { |env_name, _| ENV[env_name] = empty_value }
        cassette = record_response("#{url}?q=laos", ['ordinary-response-content'])
        expect(cassette).to include('ordinary-response-content')
        credentials.each_value { |_, placeholder| expect(cassette).not_to include(placeholder) }
      end
    end

    it "redacts #{provider} query credentials without relying on ENV" do
      credentials.each_value { |env_name, _| ENV[env_name] = nil }
      parameters = credentials.keys.to_h { |name| [name, "dummy encoded/#{name}"] }.merge('q' => 'laos')
      cassette = record_response("#{url}?#{URI.encode_www_form(parameters)}", parameters.values.take(credentials.length))
      parameters.values.take(credentials.length).each do |value|
        expect(cassette.include?(value)).to be(false)
        expect(cassette.include?(URI.encode_www_form_component(value))).to be(false)
      end
      credentials.each_value { |_, placeholder| expect(cassette).to include(placeholder) }
    end
  end

  it 'keeps credential matching strict on unrelated hosts' do
    matcher = VCR.request_matchers[:uri_without_provider_credentials]
    first = VCR::Request.new(:get, 'https://example.test/search?key=dummy-one', nil, {})
    second = VCR::Request.new(:get, 'https://example.test/search?key=dummy-two', nil, {})
    expect(matcher.matches?(first, second)).to be(false)
  end

  it 'redacts the Edamam service legacy percent prefix without corrupting the response' do
    ENV['edamam_key'] = 'dummy-edamam-legacy-key'
    cassette = record_response("https://api.edamam.com/api/recipes/v2?q=laos&app_key=%#{ENV.fetch('edamam_key')}", ['ordinary-response-content'])
    expect(cassette.include?(ENV.fetch('edamam_key'))).to be(false)
    expect(cassette).to include('app_key=<EDAMAM_API_KEY>', 'ordinary-response-content')
  end

  it 'redacts and matches percent-encoded credential names with ENV absent during recording' do
    ENV['google_api'] = nil
    cassette = record_response('https://youtube.googleapis.com/youtube/v3/search?%6Bey=dummy-encoded-name&q=laos', ['ordinary-response-content'])
    expect(cassette.include?('dummy-encoded-name')).to be(false)
    ENV['google_api'] = 'dummy-new-key'
    VCR.use_cassette('provider', record: :none, re_record_interval: nil) do
      response = Net::HTTP.get_response(URI('https://youtube.googleapis.com/youtube/v3/search?%6Bey=dummy-new-key&q=laos'))
      expect(response.code).to eq('200')
    end
  end

  it 'rejects encoded parameter names and malformed credential encoding without raising' do
    expect(unredacted_provider_parameters?('?%6Bey=dummy-unredacted')).to be(true)
    expect(unredacted_provider_parameters?('?app_key=%dummy-malformed')).to be(true)
    expect(unredacted_provider_parameters?('?app_key=%20<EDAMAM_API_KEY>')).to be(false)
  end

  it 'rejects credential URL parameters for unknown providers' do
    expect(unredacted_provider_parameters?('https://custom.example.test/?access_token=dummy-custom-token')).to be(true)
    expect(unredacted_provider_parameters?('https://custom.example.test/?access_token=/dummy-custom-token')).to be(true)
    expect(unredacted_provider_parameters?('https://custom.example.test/?access_token=<CUSTOM_TOKEN>')).to be(false)
  end

  it 'treats malformed fixture structures as violations without raising or quoting data' do
    expect(unredacted_fixture_bodies_or_headers?('dummy-malformed-fixture')).to be(true)
    expect(unredacted_fixture_bodies_or_headers?('http_interactions: [dummy-malformed-fixture]')).to be(true)
  end

  it 'rejects credentials in arbitrary fixture auth headers and nested JSON bodies' do
    fixture = { 'http_interactions' => [{
      'request' => { 'headers' => { 'Authorization' => ['Bearer dummy-custom-token'] }, 'body' => { 'string' => '' } },
      'response' => { 'headers' => {}, 'body' => { 'string' => '{"nested":{"access_token":"dummy-custom-token"}}' } }
    }] }
    expect(unredacted_fixture_bodies_or_headers?(YAML.dump(fixture))).to be(true)
    fixture['http_interactions'].first['request']['headers'] = {}
    expect(unredacted_fixture_bodies_or_headers?(YAML.dump(fixture))).to be(true)
    fixture['http_interactions'].first['response']['body']['string'] = '{"nested":{"access_token":"<CUSTOM_TOKEN>"}}'
    expect(unredacted_fixture_bodies_or_headers?(YAML.dump(fixture))).to be(false)
  end

  it 'rejects unredacted provider parameters in fixtures and Google key patterns in all tracked files' do
    root = File.expand_path('../..', __dir__)
    files, status = Open3.capture2('git', 'ls-files', '-z', chdir: root)
    expect(status.success?).to be(true)
    violations = files.split("\0").select do |file|
      text = File.binread(File.join(root, file))
      credential_pattern = text.match?(/AIza[0-9A-Za-z_-]{35}|(?:AKIA|ASIA)[A-Z0-9]{16}|gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/)
      assignment_pattern = text.scan(/\b(?:api[_-]?key|access[_-]?token|refresh[_-]?token|client[_-]?secret|secret[_-]?key|secret|password|token)["']?\s*[:=]\s*(["'])([^"'\r\n]{24,})\1/i).any? do |_, value|
        !value.start_with?('dummy-', 'dummy_') && !value.match?(/\A<[^>]+>\z/)
      end
      fixture_key = false
      if file.start_with?('spec/fixtures/vcr_cassettes/')
        fixture_key = unredacted_provider_parameters?(text) || unredacted_fixture_bodies_or_headers?(text)
      end
      credential_pattern || assignment_pattern || fixture_key
    end
    # Only filenames are reported, never the credential that triggered a failure.
    expect(violations).to eq([])
  end

  [
    'Youtube_Service_Spec/Youtube_Service_Test/returns_a_Mr_History_Video',
    'Learning_Resources_Facade_Test/Learning_Resources_Facade_Methods_test/creates_a_learning_resource_poro',
    'spec/fixtures/vcr_cassettes/Learning_Resources_Page_has_content/youtube_yml'
  ].each do |name|
    it "replays the Google fixture #{name} offline" do
      ENV['google_api'] = 'dummy-google-fixture-key'
      ENV['unsplash_key'] = 'dummy-unsplash-fixture-key'
      VCR.configure { |config| config.cassette_library_dir = File.expand_path('../fixtures/vcr_cassettes', __dir__) }
      VCR.use_cassette(name, record: :none, re_record_interval: nil) do
        if name.start_with?('Youtube_Service_Spec')
          video = YoutubeService.new.country_video('laos').fetch(:items).first
          expect(video.fetch(:id).fetch(:videoId)).not_to be_empty
        else
          resource = LearningResourcesFacade.new.learning_resource('laos')
          expect(resource.country).to eq('laos')
          expect(resource.video_id).not_to be_empty
          expect(resource.images_formatted.length).to eq(10)
        end
      end
    end
  end

  [
    'Edamam_Service_Spec/Edamam_Service_Test/returns_recipes_for_specific_country',
    'Edamam_Facade_Test/Edamam_Facade_methods/creates_recipe_poro',
    'Recipes_Index/Search_for_Recipes/Shows_a_list_of_recipes_for_country_searched_for',
    'fixtures/spec/fixtures/vcr_cassettes/Recipes_Index/Search_for_Recipes/ran_country'
  ].each do |name|
    it "replays the Edamam fixture #{name} offline" do
      ENV['edamam_id'] = 'dummy-edamam-id'
      ENV['edamam_key'] = 'dummy-edamam-key'
      library = File.expand_path('../fixtures/vcr_cassettes', __dir__)
      fixture = YAML.load_file(File.join(library, "#{name}.yml"))
      recorded_request = fixture.fetch('http_interactions').find do |interaction|
        URI(interaction.fetch('request').fetch('uri')).host == 'api.edamam.com'
      end
      uri = URI(recorded_request.fetch('request').fetch('uri'))
      country = URI.decode_www_form(uri.query).to_h.fetch('q')
      VCR.configure { |config| config.cassette_library_dir = library }
      VCR.use_cassette(name, record: :none, re_record_interval: nil) do
        recipes = EdamamFacade.new.country_recipes(country)
        expect(recipes.length).to eq(20)
        expect(recipes.first.country).to eq(country)
        expect(recipes.first.title).not_to be_empty
        expect(recipes.first.url).not_to be_empty
      end
    end
  end
end
