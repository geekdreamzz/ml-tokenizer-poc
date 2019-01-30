require 'redis'
require 'redis-namespace'

module Epiphany
  class Tokenizer
    module Cache
      REDIS_CONNECTION = Redis.new
      FRAGMENT_CACHE = Redis::Namespace.new(:fragments, :redis => REDIS_CONNECTION)
      PHRASES_CACHE = Redis::Namespace.new(:phrases, :redis => REDIS_CONNECTION)
      STRING_CACHE = Redis::Namespace.new(:returns_strings, :redis => REDIS_CONNECTION)

      class << self
        def string_fetch(str, **opts)
          val = STRING_CACHE.get(str) unless opts[:refresh]
          return val if val
          val = yield(str)
          STRING_CACHE.set(str, val)
          val
        end

        def clear_string_cache
          keys = STRING_CACHE.keys
          STRING_CACHE.del(*keys) if keys&.length > 0
        end

        def fetch_phrase(phrase, **opts)
          val = PHRASES_CACHE.get(phrase) unless opts[:refresh]
          return JSON.parse(val) if val
          val = yield(phrase).to_json
          PHRASES_CACHE.set(phrase, val)
          val
        end

        def clear_phrases_cache
          keys = PHRASES_CACHE.keys
          PHRASES_CACHE.del(*keys) if keys&.length > 0
        end

        def delete_phrase(phrase)
          PHRASES_CACHE.del(phrase)
        end
      end
      #end 'class' methods
    end
  end
end