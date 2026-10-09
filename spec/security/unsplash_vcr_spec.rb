require 'spec_helper'
require 'tmpdir'
require 'yaml'
require 'net/http'
require 'webmock/rspec'
require 'faraday'
require 'json'
require_relative '../support/vcr'
require_relative '../../app/services/unsplash_service'
require_relative '../../app/facades/learning_resources_facade'
require_relative '../../app/poros/learning_resource'

RSpec.describe 'Unsplash cassette credential protection' do
  around do |example|
    original_key = ENV['unsplash_key']
    original_library = VCR.configuration.cassette_library_dir
    WebMock.disable_net_connect!
    Dir.mktmpdir('unsplash-vcr') do |directory|
      VCR.configure { |config| config.cassette_library_dir = directory }
      example.run
    end
  ensure
    ENV['unsplash_key'] = original_key
    VCR.configure { |config| config.cassette_library_dir = original_library }
  end

  def record_response(key)
    uri = "https://api.unsplash.com/search/photos?client_id=#{key}&query=laos"
    interaction = VCR::HTTPInteraction.new(
      VCR::Request.new(:get, uri, nil, {}),
      VCR::Response.new(
        VCR::ResponseStatus.new(200, 'OK'),
        { 'Content-Type' => ['application/json'],
          'Link' => ["<#{uri}&page=2>; rel=\"next\""] },
        '{"results":[{"description":"Laos"}]}', '1.1'
      )
    )
    VCR.use_cassette('redaction', record: :all) do
      VCR.record_http_interaction(interaction)
    end
    File.read(File.join(VCR.configuration.cassette_library_dir, 'redaction.yml'))
  end

  it 'redacts requests and response links, then replays with a different dummy key' do
    ENV['unsplash_key'] = 'dummy-unsplash-recording-key'
    cassette = record_response(ENV.fetch('unsplash_key'))
    expect(cassette.include?(ENV.fetch('unsplash_key'))).to be(false)
    recorded = YAML.safe_load(cassette)
    interaction = recorded.fetch('http_interactions').first
    expect(interaction.fetch('request').fetch('uri')).to include('client_id=<UNSPLASH_ACCESS_KEY>')
    expect(interaction.fetch('response').fetch('headers').fetch('Link').first).to include('client_id=<UNSPLASH_ACCESS_KEY>')

    ENV['unsplash_key'] = 'dummy-unsplash-playback-key'
    VCR.use_cassette('redaction', record: :none, re_record_interval: nil) do
      response = Net::HTTP.get_response(URI("https://api.unsplash.com/search/photos?client_id=#{ENV.fetch('unsplash_key')}&query=laos"))
      expect(response.code).to eq('200')
      expect(response.body).to eq('{"results":[{"description":"Laos"}]}')
      expect(response['Link']).to include(ENV.fetch('unsplash_key'))
    end
  end

  [nil, ''].each do |key|
    it "leaves unrelated content intact when the key is #{key.nil? ? 'unset' : 'empty'}" do
      ENV['unsplash_key'] = key
      cassette = record_response('dummy-unconfigured-key')
      expect(cassette).to include('client_id=dummy-unconfigured-key')
      expect(cassette).not_to include('<UNSPLASH_ACCESS_KEY>')
    end
  end

  it 'keeps all committed cassette client_id values redacted' do
    root = File.expand_path('../fixtures/vcr_cassettes', __dir__)
    files = Dir.glob(File.join(root, '**', '*.yml'))
    expect(files).not_to be_empty
    violations = files.select do |file|
      # Boolean check deliberately avoids displaying a credential on failure.
      File.read(file).scan(/client_id=([^&\s]+)/).flatten.any? do |value|
        value != '<UNSPLASH_ACCESS_KEY>' && value != '%3CUNSPLASH_ACCESS_KEY%3E'
      end
    end
    expect(violations.map { |file| file.delete_prefix(root) }).to eq([])
  end

  [
    'Unsplash_Service_Spec/Unsplash_Service_Test/returns_10_images',
    'Learning_Resources_Facade_Test/Learning_Resources_Facade_Methods_test/creates_a_learning_resource_poro',
    'spec/fixtures/vcr_cassettes/Learning_Resources_Page_has_content/youtube_yml'
  ].each do |name|
    it "replays the sanitized #{name} fixture offline" do
      ENV['unsplash_key'] = 'dummy-unsplash-fixture-playback-key'
      VCR.configure do |config|
        config.cassette_library_dir = File.expand_path('../fixtures/vcr_cassettes', __dir__)
      end
      VCR.use_cassette(name, record: :none, re_record_interval: nil) do
        # Exercise the facade and PORO using the recorded Unsplash response.
        # The unrelated YouTube request is replaced with a local dummy response.
        facade = LearningResourcesFacade.new
        youtube = double('YouTube service', country_video: {
          items: [{ id: { videoId: 'dummy-video' }, snippet: { title: 'Laos' } }]
        })
        allow(facade).to receive(:youtube_service).and_return(youtube)
        resource = facade.learning_resource('laos')
        expect(resource.country).to eq('laos')
        expect(resource.video_id).to eq('dummy-video')
        expect(resource.images_formatted.length).to eq(10)
        expect(resource.images_formatted.first.keys).to eq([:alt_tag, :url])
      end
    end
  end
end
