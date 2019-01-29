module Epiphany
  class Tokenizer
    module IntentScorer

      def all_entities
        @all_entities ||= (tokens.map(&:all_entities).flatten.uniq + fragment_entities).uniq
      end

      # fragments make up a token, but they're the same for the whole tokenizer
      # be sure to call this on the tokenizer and not recursively
      # on each token since it's the same fragment objects
      def fragment_entities
        @fragment_entities ||= fragments.map do |fragment|

          self.class.text_match_entity_types.map do |entity_type|
            if entity_type.phrases_for_validation.include?(fragment.normalized_phrase)
              entity = Struct.new(:type, :phrase)
              entity.new(entity_type.type, fragment.normalized_phrase)
            end
          end.compact + fragment.detected_parts_of_speech

        end.flatten.compact
      end

      def top_scored_intent
        top_intent[:intent_type] if sorted_scores.length > 0
      end

      def top_intent
        sorted_scores.first
      end

      def scores_quick_report
        sorted_scores.map{|s| "#{s[:intent_type]} => #{s[:score]}" }.join(', ')
      end

      def sorted_scores
        @sorted_scores ||= calculated_scores.sort_by{|intent| intent[:score] }.reverse
      end

      def entities_for(_intent)
        _entities = {}
        _intent[:entities].each do |e|
          _entities[e[:entity]] ||= []
          _entities[e[:entity]] += e[:match].map {|m| m.phrase }.compact.uniq
        end
        _entities
      end

      def results_hash
        {
            phrase: phrase,
            top_scored_intent: top_scored_intent,
            score: top_intent[:score],
            matched_entities: entities_for(top_intent)
        }
      end

      def calculated_scores
        @calculated_scores ||= self.class.intent_types.map do |intent_type|

          required_entities = intent_type.required_entities.map do |required_entity|
            {
                entity: required_entity,
                match: all_entities.select do |entity|
                  entity.type.to_s == required_entity.to_s
                end
            }
          end

          optional_entities = intent_type.optional_entities.map do |optional_entity|
            {
                entity: optional_entity,
                match: all_entities.select do |entity|
                  entity.type.to_s == optional_entity.to_s
                end
            }
          end

          matches = required_entities.select{|r| r[:match].length > 0 }

          union = matches.map{|m|m[:entity]}.uniq & required_entities.map{|r| r[:entity]}

          if union == required_entities.map{|r| r[:entity]}
            score = matches.length.to_f + optional_entities.length.to_f
            fragments.map(&:normalized_phrase).each do |_frag|
              score += _frag.length.to_f if intent_type.keywords_boost.include?(_frag)
            end
          else
            score = 0.0
          end
          score = 0.0 if score.nan?
          {
              score: score,
              entities: matches,
              intent_type: intent_type.type,
              token: self
          }
        end
      end
    end
  end
end
