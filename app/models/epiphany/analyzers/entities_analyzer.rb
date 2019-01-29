require_relative '../tokenizer_analyzer'

module EntitiesAnalyzer
  include Epiphany::Tokenizer::Analyzer

  analyzer priority: 100003,
           callback_method_names: [:all_entities] #TODO validate this is an array on the class method

  def entity_types
    @entity_types ||= parent_tokenizer.class.all_entity_types
  end

  def text_match_entity_types
    @text_match_entity_types ||= entity_types.select{|et| et.validation_type == "text_match"}
  end

  def custom_analyzer_entity_types
    @custom_analyzer_entity_types ||= entity_types.select{|et| et.validation_type == "custom_analyzer"}
  end

  def lib_entities
    @lib_entities ||= (text_match_entities + detected_parts_of_speech)
  end

  def text_match_entities
    @text_match_entities ||= text_match_entity_types.map do |entity_type|
      if entity_type.phrases_for_validation.include?(phrase)
        entity = Struct.new(:type, :phrase)
        entity.new(entity_type.type, phrase)
      end
    end.compact + fragment_entities
  end

  def fragment_entities
    fragments.map(&:text_match_entities).flatten.compact
  end

  def custom_analyzer_entities(current_analyzer = nil)
    return [] if current_analyzer
    @custom_analyzer_entities ||= custom_analyzer_entity_types.map do |entity_type|
      if entity_type.validation_type == 'custom_analyzer'
        entity = Struct.new(:type, :phrase)
        analyzer = entity_type.custom_analyzer.new(token = self, entity_type)
        if analyzer.valid_entity?
          entity.new(entity_type.type, analyzer.validated_entity_value)
        end
      end
    end.compact
  end

  def all_entities(current_analyzer = nil)
    @all_entities ||= (lib_entities + custom_analyzer_entities(current_analyzer)).flatten.compact.uniq
  end
end
