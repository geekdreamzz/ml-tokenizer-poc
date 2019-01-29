module Epiphany
  class CustomAnalyzer
    extend ::Forwardable
    attr_reader :token, :args, :entity_type

    def_delegators :@token, :phrase, :can_be?, :entity_types, :postion, :splitted_phrase, :all_entities, :fragments
    def_delegators :@entity_type, :known_phrases, :phrases_for_validation, :required_entities, :validation_type, :type

    def initialize(token, entity_type, **args)
      @token = token
      @entity_type = entity_type
      @args = args
    end

    #
    # TODO provide resource docs on custom analyzers
    # ex: talk about token and entity_type
    # what they should be doing. etc.
    #

    def current_fragment
      token.parent_tokenizer.fragments.find {|f| f.normalized_phrase == phrase }
    end

    def current_indx
      token.parent_tokenizer.fragments.index(current_fragment)
    end

    def previous_fragment
      return unless current_fragment
      token.parent_tokenizer.fragments[current_indx - 1] unless current_indx == 0
    end

    def next_fragment
      return unless current_fragment
      token.parent_tokenizer.fragments[current_indx + 1]
    end

    def has_required_entities?
      (required_entities & all_entities(self).map{|me| me.type.to_sym}).length == required_entities.length
    end

    def validated_entity_value
      return phrase
      raise StandardError.new("you must override this method in your custom analyzer with the value of the detected entity.")
      #stub so child classes can override return value after it does it's custom analysis
    end

    def valid_entity?
      return false unless has_required_entities?
      raise StandardError.new("you must override this method to true of false")
      #stub so child classes can override to true after it does it's custom analysis
    end
  end
end
