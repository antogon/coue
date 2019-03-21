require 'geocoder'
require 'geocoder/lookups/google'
require 'geocoder/lookups/google_places_search'
require 'geocoder/lookups/here'

module Coue
  module Geocoder
    module Query
      def complete?
        options[:complete]
      end
    end

    module Lookup
      module Base
        def query_url(query)
          return autocomplete_query_url + url_query_string(query) if query.complete?

          base_query_url(query) + url_query_string(query)
        end
      end

      module Google
        include ::Coue::Geocoder::Lookup::Base
      end

      module GooglePlacesSearch
        include ::Coue::Geocoder::Lookup::Base
        include ::Coue::Geocoder::Lookup::Google

        def autocomplete_query_url
          "#{protocol}://maps.googleapis.com/maps/api/place/autocomplete/json?"
        end

        def query_url_google_params(query)
          return autocomplete_query_params(query) if query.complete?

          {
            query: query.text,
            language: query.language || configuration.language
          }
        end

        def autocomplete_query_params(query)
          { input: query.text }
        end
      end

      module Here
        include ::Coue::Geocoder::Lookup::Base

        def autocomplete_query_url
          "#{protocol}://autocomplete.geocoder.api.here.com/6.2/suggest.json?"
        end

        def query_url_params(query)
          if query.reverse_geocode?
            super.merge(query_url_here_options(query, true)).merge(
              prox: query.sanitized_text
            )
          elsif query.complete?
            super.merge(query_url_here_options(query, false)).merge(
              :query=>query.sanitized_text
            )
          else
            super.merge(query_url_here_options(query, false)).merge(
              searchtext: query.sanitized_text
            )
          end
        end
      end
    end
  end
end

::Geocoder::Query.include Coue::Geocoder::Query
::Geocoder::Lookup::Google.include Coue::Geocoder::Lookup::Google
::Geocoder::Lookup::GooglePlacesSearch.include Coue::Geocoder::Lookup::GooglePlacesSearch
::Geocoder::Lookup::Here.include Coue::Geocoder::Lookup::Here

# I do not know why including this method does not do it, but it does not...
# I would appreciate someone educating me.  for now, class_eval it is.
::Geocoder::Lookup::Here.class_eval do
  private

    def results(query)
      return [] unless doc = fetch_data(query)

      if query.complete?
        r = doc['suggestions']
        return r.nil? || !r.is_a?(Array) || r.empty? ? [] : r
      end

      return [] unless doc['Response'] && doc['Response']['View']
      if r=doc['Response']['View']
        return [] if r.nil? || !r.is_a?(Array) || r.empty?
        return r.first['Result']
      end
      []
    end
end

::Geocoder::Lookup::Google.class_eval do
  private

    def results(query)
      return [] unless doc = fetch_data(query)
      case doc['status']; when "OK" # OK status implies >0 results
        return query.complete? ? doc['predictions'] : doc['results']
      when "OVER_QUERY_LIMIT"
        raise_error(Geocoder::OverQueryLimitError) ||
          Geocoder.log(:warn, "#{name} API error: over query limit.")
      when "REQUEST_DENIED"
        raise_error(Geocoder::RequestDenied, doc['error_message']) ||
          Geocoder.log(:warn, "#{name} API error: request denied (#{doc['error_message']}).")
      when "INVALID_REQUEST"
        raise_error(Geocoder::InvalidRequest, doc['error_message']) ||
          Geocoder.log(:warn, "#{name} API error: invalid request (#{doc['error_message']}).")
      end
      return []
    end
end
