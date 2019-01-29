require_relative '../epiphany/custom_analyzer'

class RepsCountAnalyzer < Epiphany::CustomAnalyzer
  def regex_matches?
    phrase.match(/^(\d+ \b\w+\b)$/i)
  end

  def validated_entity_value
    phrase
  end

  def valid_entity?
    #stop functions
    return false unless has_required_entities?
    return false unless regex_matches?
    true
  end
end