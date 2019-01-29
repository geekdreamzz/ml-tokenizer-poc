require_relative '../tokenizer_analyzer'

module FragmentsAnalyzer
  include Epiphany::Tokenizer::Analyzer
  analyzer priority: 100002,
           callback_method_names: [:detected_parts_of_speech]

  def detected_parts_of_speech
    @detected_parts_of_speech ||= fragments.map(&:detected_parts_of_speech).flatten
  end

  def can_be?(pos)
    fragments.map {|f| f.can_be?(pos) }.any?
  end
end
