#require 'nokogiri'
#require 'open-uri'

module Epiphany
  class Tokenizer
    class Fragment
      DEFAULT_VALIDATORS = %w{noun pronoun verb adjective adverb preposition conjunction interjection integer}.freeze

      def initialize(phrase, index, **opts)
        @phrase = phrase
        @index = index
        @opts = opts
        fetch_definitions
      end

      def phrase
        @phrase
      end

      def index
        @index
      end

      def normalized_phrase
        phrase.gsub(/\W/,'')
      end

      def definitions
        definitions_hash.values
      end

      def parts_of_speech
        definitions_hash.keys
      end

      def definitions_hash
        @definitions_hash ||= {}
      end

      def can_be?(val)
        if val.match(/integer|number/i)
          is_number?
        else
          parts_of_speech.map{|p| p.match(/#{val}/i) }.any?
        end
      end

      def is_number?
        normalized_phrase.to_i.to_s == normalized_phrase
      end

      # temporary POC - might need to try something else
      # uses nokogiri to parse word definitions from dictionary.com
      # TODO seek permission / partnership with dictionary.com
      def fetch_definitions
        return if stop
        begin
          doc = Nokogiri::HTML(dictionary_uri)
          sections = doc.css('.default-content').search('section')
          sections[1,sections.length].each do |section|
            definition_from(section)
          end
        rescue Exception => e
          if e.message == "404 Not Found"
            #TODO handle 404s ?
            write_to_cache
          else
            #puts "Error fetching #{normalized_phrase} trying :single_definition_parser"
            single_definition_parser(doc)
          end
        end
      end

      def single_definition_parser(doc)
        begin
          definition_from(doc.at('section').at('section').search('section')[1])
        rescue
          #puts "Error fetching #{normalized_phrase} trying "
          #TODO next_parser if needed
          # binding.pry
        end
      end

      def definition_from(section)
        pos = section.search('h3').text
        definitions_hash[pos] ||= []
        section.at('div').children.each do |definition|
          definitions_hash[pos] << definition.text
        end
        write_to_cache
      end

      def detected_parts_of_speech
        @detected_parts_of_speech ||= DEFAULT_VALIDATORS.map do |pos|
          if can_be? pos
            entity = Struct.new(:type, :phrase)
            entity.new(pos, normalized_phrase)
          end
        end.compact
      end

      def text_match_entity_types
        @entity_types ||= Epiphany::Tokenizer.text_match_entity_types
      end

      #TODO figure out callback method flow
      def text_match_entities
        @text_match_entities ||= text_match_entity_types.map do |entity_type|
          if entity_type.phrases_for_validation.include?(normalized_phrase)
            entity = Struct.new(:type, :phrase)
            entity.new(entity_type.type, normalized_phrase)
          end
        end.compact

        # TODO figure out callback method flow
        # should it happen here?
      end
      private
      def stop
        is_cached? || is_number?
      end

      def init_from(cache)
        @definitions_hash = JSON.parse(cache)
      end

      def is_cached?
        cache = Epiphany::Tokenizer::FRAGMENT_CACHE.get(normalized_phrase)
        init_from(cache) if cache
        !!cache
      end

      def write_to_cache
        return if definitions_hash.keys.length == 0
        Epiphany::Tokenizer::FRAGMENT_CACHE.set(normalized_phrase, definitions_hash.to_json)
      end

      def dictionary_uri
        if Epiphany::Config.has_proxy?
          open("https://dictionary.com/browse/#{normalized_phrase}", proxy: Epiphany::Config.http_proxy)
        else
          open("https://dictionary.com/browse/#{normalized_phrase}")
        end
      end
    end
  end
end
