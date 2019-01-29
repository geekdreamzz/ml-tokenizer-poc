require_relative '../epiphany/custom_analyzer'

class WeightLiftAnalyzer < Epiphany::CustomAnalyzer
  def regex_matches?
    phrase.match(/^(\d+ \b\w+\b)$/i)
  end

  def validated_entity_value
    phrase
  end

  def previous_fragment_is_weight_exercise?
    return false unless previous_fragment
    previous_fragment.text_match_entities.select{|entity_type|  entity_type.type.to_s == "weighted_exercise" }.length > 0
  end

  def next_fragment_is_not_weight_exercise?
    return false unless next_fragment
    next_fragment.text_match_entities.select{|entity_type|  entity_type.type.to_s == "weighted_exercise" }.length == 0
  end

  def phrase_int?
    phrase.to_i.to_s == phrase
  end

  def valid_entity?
    # binding.pry if phrase == "315"
    # binding.pry if phrase == "add 10 reps of 145 lbs"
    return true if previous_fragment_is_weight_exercise? && phrase_int? && next_fragment_is_not_weight_exercise?
    # #stop functions
    return false unless has_required_entities?
    regex_matches?
  end
end