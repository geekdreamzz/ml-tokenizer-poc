require_relative 'tokenizer_schema'

module Epiphany
  class EntityType
    attr_reader :type, :validation_type, :known_phrases, :required_entities, :custom_analyzer

    def initialize(filepath, args)
      @type = args["type"] || args[:type] || filepath.match(/(\w+)(.json)/i)[0].gsub('.json','')
      @validation_type = args["validation_type"] || args[:validation_type]
      @known_phrases = args["known_phrases"] || args[:known_phrases] || []
      @required_entities = args["required_entities"] || args[:required_entities] || []
      @custom_analyzer = args["custom_analyzer"] || args[:custom_analyzer]
      @type.freeze
      @validation_type.freeze
      @known_phrases.freeze
      @required_entities.freeze
      @custom_analyzer.freeze
    end

    def display_name
      type.gsub('_', ' ')
    end

    def phrases_for_validation
      @phrases_for_validation ||= known_phrases.map do |phrase|
        p = phrase.downcase
        [p.singularize, p, p.pluralize]
      end.flatten.compact.uniq
    end

    class << self
      def all
        Epiphany::Tokenizer::Schema.all_entity_types
      end
    end
  end
end
