require_relative '../tokenizer_analyzer'

module BaseAnalyzer
  include Epiphany::Tokenizer::Analyzer
  analyzer priority: 100004

  def intents
    @intents ||= []
  end

  def entities
    @entities ||= []
  end

  def add_intent(intent, &block)
    #TODO validation
    intents << intent
  end

  def add_entity(intent, &block)
    #TODO validation
    entities << intent
  end

  def position
    parent_tokenizer.tokens.index(self)
  end

  def family_count
    parent_tokenizer.tokens.count
  end

  def last_token_index
    family_count - 1
  end

  def splitted_phrase
    @splitted_phrase ||= phrase.split(' ')
  end
end