require 'bundler'
Bundler.require(:default, :test)
require 'minitest/autorun'

require 'coue'

class BasicGeocoderIntegration < Minitest::Test
  def test_geocoder_config_exists
    config = ::Geocoder.config
    assert(!config.nil?)
  end

  def test_geocoder_query_complete
    query = ::Geocoder::Query.new('Somewhere', complete: true)
    assert_respond_to(query, :complete?)
    assert(query.complete?)
    query = ::Geocoder::Query.new('Somewhere')
    assert(!query.complete?)
  end

  def test_here_use_autocomplete_query_url
    lookup = ::Geocoder::Lookup::Here.new
    url = lookup.query_url(
      ::Geocoder::Query.new(
        'Some Intersection',
        complete: true
      )
    )
    assert_match(/autocomplete.geocoder.api.here.com/, url)
  end

  def test_google_places_use_autocomplete_query_url
    lookup = ::Geocoder::Lookup::GooglePlacesSearch.new
    url = lookup.query_url(
      ::Geocoder::Query.new(
        'Some Intersection',
        complete: true
      )
    )
    assert_match(/maps\/api\/place\/autocomplete/, url)
  end

  def test_calls_here_suggest_api_from_top_level_interface
    Geocoder.configure(
      lookup: :here,
      api_key: ['somegarbage', 'moregarbage']
    )
    stub_request(
      :get,
      /autocomplete.geocoder.api.here.com\/6.2\/suggest.json/
    ).to_return do |request|
      file = File.read "test/fixtures/here_suggest.json"
      { status: 200, body: file }
    end
    result = Geocoder.search("Paris", complete: true)
    assert(result.size == 5)
  end

  def test_calls_google_places_search_suggest_api_from_top_level_interface
    Geocoder.configure(
      lookup: :google_places_search,
      api_key: 'somegarbage'
    )
    stub_request(
      :get,
      /maps.googleapis.com\/maps\/api\/place\/autocomplete\/json/
    ).to_return do |request|
      file = File.read "test/fixtures/google_places_search_suggest.json"
      { status: 200, body: file }
    end
    result = Geocoder.search("Paris", complete: true)
    assert(result.size == 1)
  end
end
