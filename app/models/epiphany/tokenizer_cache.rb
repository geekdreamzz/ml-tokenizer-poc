require 'redis'
require 'redis-namespace'

module Epiphany
  class Tokenizer
    module Cache
      REDIS_CONNECTION = Redis.new
      FRAGMENT_CACHE = Redis::Namespace.new(:fragments, :redis => REDIS_CONNECTION)
      PHRASES_CACHE = Redis::Namespace.new(:phrases, :redis => REDIS_CONNECTION)
      STRING_CACHE = Redis::Namespace.new(:returns_strings, :redis => REDIS_CONNECTION)
      ENTITY_TYPE_CACHE = Redis::Namespace.new(:entity_types, :redis => REDIS_CONNECTION)
      INTENT_TYPE_CACHE = Redis::Namespace.new(:intent_types, :redis => REDIS_CONNECTION)

      class << self
        #GET ALL within a namespace
        def all_entity_types
          keys = ENTITY_TYPE_CACHE.keys
          return [] unless keys.present?
          ets = ENTITY_TYPE_CACHE.mget(*keys)
          ets.map do |et|
            data = JSON.parse(et)
            Epiphany::EntityType.new(data)
          end
        end

        def all_intent_types
          keys = INTENT_TYPE_CACHE.keys
          return [] unless keys.present?
          its = INTENT_TYPE_CACHE.mget(*keys)
          its.map do |it|
            binding.pry
            intent_type = data.keys.first
            data.merge! data[intent_type]
            data[:type] = intent_type
            IntentType.new(path, data)
          end
        end

        #reset / set
        def set_entity_type(type, **opts)
          val = yield.to_json
          ENTITY_TYPE_CACHE.set(type, val)
          val
        end

        #FETCHES


        def string_fetch(str, **opts)
          val = STRING_CACHE.get(str) unless opts[:refresh]
          return val if val
          val = yield(str)
          STRING_CACHE.set(str, val)
          val
        end

        def fetch_phrase(phrase, **opts)
          val = PHRASES_CACHE.get(phrase) unless opts[:refresh]
          return JSON.parse(val) if val
          val = yield(phrase).to_json
          PHRASES_CACHE.set(phrase, val)
          val
        end

        #DELETES
        def clear_entity_type_cache
          keys = ENTITY_TYPE_CACHE.keys
          ENTITY_TYPE_CACHE.del(*keys) if keys&.length > 0
        end

        def clear_string_cache
          keys = STRING_CACHE.keys
          STRING_CACHE.del(*keys) if keys&.length > 0
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