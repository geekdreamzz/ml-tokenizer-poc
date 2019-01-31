require 'json'

require_relative 'tokenizer_schema'
require_relative 'tokenizer_intent_scorer'
require_relative 'tokenizer_token'
require_relative 'tokenizer_fragment'
require_relative 'tokenizer_cache'

module Epiphany
  class Tokenizer
    include Schema
    include IntentScorer
    include Cache

    FRAGMENT_CACHE = Cache::FRAGMENT_CACHE

    def initialize(phrase, **opts)
      @phrase = phrase
      @phrase.freeze
      tokens unless opts[:init_without_tokens]
      analyze_tokens!
      final_callbacks
    end

    def custom_analyzer_entity_types
      @custom_analyzers ||= self.class.custom_analyzer_entity_types
    end

    def phrase
      @phrase
    end

    def fragments
      return @fragments if defined? @fragments
      @fragments = []
      phrase.split(' ').each_with_index do |fragment, index|
        @fragments << Fragment.new(fragment, index)
      end
      @fragments.freeze
    end

    def tokens
      @tokens ||= fragments.map do |fragment|
        (fragment.index..fragments.length - 1).map do |enumerating_index|
          grouped_fragment = grouped_fragments(fragment.index, enumerating_index)
          token_phrase = grouped_fragment_phrase(grouped_fragment)
          Token.new(self, token_phrase, grouped_fragment)
        end.flatten.compact
      end.flatten.compact.freeze
    end

    def analyze_tokens!
      tokens.each(&:execute_analysis)
    end

    def grouped_fragments(start_idx, end_idx)
      (start_idx..end_idx).map do |idx|
        fragments[idx]
      end
    end

    def grouped_fragment_phrase(grouped_fragment)
      grouped_fragment.map(&:phrase).join(' ')
    end

    def token_phrases
      @token_phrases ||= tokens.map(&:phrase)
    end

    def final_callbacks
      "token analysis complete! override this method to do some post processing =)"
    end
  end
end
