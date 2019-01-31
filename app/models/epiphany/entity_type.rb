require "active_support/core_ext/hash/indifferent_access"
require_relative 'tokenizer_schema'

module Epiphany
  class EntityType
    attr_reader :type, :name, :validation_type, :required_entities, :custom_analyzer, :match_phrases

    def initialize(args)
      args = args.with_indifferent_access
      @type = args['name']
      @name = args['name']
      @validation_type = args['validation_type'] || 'text_match'
      @match_phrases = args['match_phrases'] || []
      @required_entities = args['required_entities']&.map(&:to_s) || []
      @custom_analyzer = args["custom_analyzer"]
    end

    def known_phrases
      @match_phrases.keys
    end

    def display_name
      type.gsub('_', ' ')
    end

    def phrases_for_validation
      @phrases_for_validation ||= known_phrases.map do |phrase|
        p = phrase.downcase
        [p.singularize, p, p.singularize.pluralize]
      end.flatten.compact.uniq
    end

    class << self
      def all
        Epiphany::Tokenizer::Schema.all_entity_types
      end
    end
  end
end
