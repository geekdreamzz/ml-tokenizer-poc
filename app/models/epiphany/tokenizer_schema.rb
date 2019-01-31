require 'active_support/concern'
require 'active_support/inflector'
require_relative 'entity_type'
require_relative 'intent_type'
require_relative 'tokenizer_cache'

module Epiphany
  class Tokenizer
    module Schema
      extend ActiveSupport::Concern

      class << self
        def phrase_tokenizer_dictionary
          @phrase_tokenizer_dictionary ||= {}
        end

        def all_entity_types
          default_entity_types + custom_entity_types.values.compact
        end

        def text_match_entity_types
          @text_match_entity_types ||= all_entity_types.select{|e| e.validation_type == 'text_match'}
        end

        def custom_analyzer_entity_types
          @custom_analyzer_entity_types ||= custom_entity_types.values.compact
        end

        def intent_types
          @_intent_types ||= default_intent_types | custom_intents.values
        end

        #
        # This module is used to boot load a ~json ~schema
        #
        # Epiphany::Tokenizer has a class method to define specific entity_types or intent_types
        # which exists in the Epiphany Open Source Library
        #
        # If left blank it will grab all of the  default
        # entity_types and intent_types in the Epiphany Open Source Library
        # which are all located at:
        # lib/epiphany/entity_types/*.json
        # lib/epiphany/intent_types/*.json
        #
        # Otherwise you can specify the specific files in the library you want.
        # example:
        #
        # class SampleTokenizer < Epiphany::Tokenizer
        #   default_intent_types :track_exercise
        #   default_entity_types :exercise, :metric, :weighted_lift
        # end
        #
        def default_entity_types(*args)
          Epiphany::Tokenizer::Cache.all_entity_types
        end

        def default_intent_types(*args)
          Epiphany::Tokenizer::Cache.all_intent_types
        end

        def file_paths_for(type, names)
          if names.length > 1
            names.flatten.map do |name|
              Dir[File.join(Epiphany::Engine.root, 'lib', 'epiphany', type, "#{name}.json")]
            end.flatten
          else
            Dir[File.join(Epiphany::Engine.root, 'lib', 'epiphany', type, "*.json")]
          end
        end

        def validate_custom_args(args)
          filepath = args[:conf_filepath] || args[:conf_file_path]
          raise ArgumentError.new("name: is required for Tokenizer custom_entity.") unless args[:name]
          raise ArgumentError.new("conf_filepath: is required for Tokenizer custom_entity.") unless filepath
          raise ArgumentError.new("conf_filepath: #{filepath} : ERROR - provided conf file does not exists") unless File.file?(filepath)
          conf = JSON.parse(File.read(filepath))
          conf.merge! "type" => args[:name].to_s
          [args[:name], conf]
        end

        # TODO should we throw an exception if some tries to add to an "existing" key?
        # if not it'll override the previous config and we probably should throw an error
        # telling them they need to rename / resolve it however they seem fit.
        def custom_entity_types
          @_custom_entity_types ||= {}
        end

        def custom_intents
          @_custom_intents ||= {}
        end

        def get_custom_analyzers
          @custom_entity_analyzers ||= custom_entity_types.values
        end

        #
        # custom_entity_type_by_callback & custom_intent_type_by_callback
        # Epiphany lib does not force you to create json files
        # this custom callback feature allows you to define your entity or intent
        # dynamically from your own rules
        # #TODO add resource link
        # required params:
        # example:
        #
        def custom_entity_type_and_analyzer(**args)
          validate_entity_analyzer_args(args)
          custom_entity_types[args[:type]] = Epiphany::EntityType.new(args)
        end

        def custom_intent_type_by_callback(**args)
          validate_intent_callback_args(args)
          custom_intents[args[:type]] = IntentType.new(args[:type], args)
        end

        def validate_entity_analyzer_args(args)
          raise ArgumentError.new("entity_name: is required for Tokenizer custom entity callback.") unless args[:entity_name]
          raise ArgumentError.new("entity_name: must be a symbol Tokenizer custom entity callback.") unless args[:entity_name].is_a? Symbol
          raise ArgumentError.new("custom_analyzer: is required for Tokenizer custom entity type analyzer.") unless args[:custom_analyzer]
          raise ArgumentError.new("custom_analyzer: must be a subclass of Epiphany::Phrase::CustomAnalyzer") unless args[:custom_analyzer].superclass == Epiphany::CustomAnalyzer
          args[:type] = args[:entity_name].to_s
          args[:name] = args[:entity_name].to_s
          args[:validation_type] = "custom_analyzer"
          args
        end

        def validate_intent_callback_args(args)
          raise ArgumentError.new("intent_name: is required for Tokenizer custom intent callback.") unless args[:intent_name]
          raise ArgumentError.new("intent_name: must be a symbol Tokenizer custom intent callback.") unless args[:intent_name].is_a? Symbol
          raise ArgumentError.new("required_entities: [:some_entity] is required for Tokenizer custom intent callback.") unless args[:required_entities]
          args[:type] = args[:intent_name].to_s
          args[:name] = args[:intent_name].to_s
          args
        end
      end
      # end class << self methods
      #

      class_methods do
        def phrase_tokenizer_dictionary
          @phrase_tokenizer_dictionary ||= {}
        end

        def all_entity_types
          default_entity_types + custom_entity_types.values.compact
        end

        def text_match_entity_types
          @text_match_entity_types ||= all_entity_types.select{|e| e.validation_type == 'text_match'}
        end

        def custom_analyzer_entity_types
          @custom_analyzer_entity_types ||= custom_entity_types.values.compact
        end

        def intent_types
          @_intent_types ||= default_intent_types | custom_intents.values
        end

        #
        # This module is used to boot load a ~json ~schema
        #
        # Epiphany::Tokenizer has a class method to define specific entity_types or intent_types
        # which exists in the Epiphany Open Source Library
        #
        # If left blank it will grab all of the  default
        # entity_types and intent_types in the Epiphany Open Source Library
        # which are all located at:
        # lib/epiphany/entity_types/*.json
        # lib/epiphany/intent_types/*.json
        #
        # Otherwise you can specify the specific files in the library you want.
        # example:
        #
        # class SampleTokenizer < Epiphany::Tokenizer
        #   default_intent_types :track_exercise
        #   default_entity_types :exercise, :metric, :weighted_lift
        # end
        #
        def default_entity_types(*args)
          Epiphany::Tokenizer::Cache.all_entity_types
        end

        def default_intent_types(*args)
          Epiphany::Tokenizer::Cache.all_intent_types
        end

        def file_paths_for(type, names)
          if names.length > 1
            names.flatten.map do |name|
              Dir[File.join(Epiphany::Engine.root, 'lib', 'epiphany', type, "#{name}.json")]
            end.flatten
          else
            Dir[File.join(Epiphany::Engine.root, 'lib', 'epiphany', type, "*.json")]
          end
        end

        def validate_custom_args(args)
          filepath = args[:conf_filepath] || args[:conf_file_path]
          raise ArgumentError.new("name: is required for Tokenizer custom_entity.") unless args[:name]
          raise ArgumentError.new("conf_filepath: is required for Tokenizer custom_entity.") unless filepath
          raise ArgumentError.new("conf_filepath: #{filepath} : ERROR - provided conf file does not exists") unless File.file?(filepath)
          conf = JSON.parse(File.read(filepath))
          conf.merge! "type" => args[:name].to_s
          [args[:name], conf]
        end

        # TODO should we throw an exception if some tries to add to an "existing" key?
        # if not it'll override the previous config and we probably should throw an error
        # telling them they need to rename / resolve it however they seem fit.
        def custom_entity_types
          @_custom_entity_types ||= {}
        end

        def custom_intents
          @_custom_intents ||= {}
        end

        def get_custom_analyzers
          @custom_entity_analyzers ||= custom_entity_types.values
        end

        #
        # custom_entity_type_by_callback & custom_intent_type_by_callback
        # Epiphany lib does not force you to create json files
        # this custom callback feature allows you to define your entity or intent
        # dynamically from your own rules
        # #TODO add resource link
        # required params:
        # example:
        #
        def custom_entity_type_and_analyzer(**args)
          validate_entity_analyzer_args(args)
          custom_entity_types[args[:type]] = Epiphany::EntityType.new(args)
        end

        def custom_intent_type_by_callback(**args)
          validate_intent_callback_args(args)
          custom_intents[args[:type]] = IntentType.new(args[:type], args)
        end

        def validate_entity_analyzer_args(args)
          raise ArgumentError.new("entity_name: is required for Tokenizer custom entity callback.") unless args[:entity_name]
          raise ArgumentError.new("entity_name: must be a symbol Tokenizer custom entity callback.") unless args[:entity_name].is_a? Symbol
          raise ArgumentError.new("custom_analyzer: is required for Tokenizer custom entity type analyzer.") unless args[:custom_analyzer]
          raise ArgumentError.new("custom_analyzer: must be a subclass of Epiphany::Phrase::CustomAnalyzer") unless args[:custom_analyzer].superclass == Epiphany::CustomAnalyzer
          args[:name] = args[:entity_name].to_s
          args[:validation_type] = "custom_analyzer"
          args
        end

        def validate_intent_callback_args(args)
          raise ArgumentError.new("intent_name: is required for Tokenizer custom intent callback.") unless args[:intent_name]
          raise ArgumentError.new("intent_name: must be a symbol Tokenizer custom intent callback.") unless args[:intent_name].is_a? Symbol
          raise ArgumentError.new("required_entities: [:some_entity] is required for Tokenizer custom intent callback.") unless args[:required_entities]
          args[:type] = args[:intent_name].to_s
          args[:name] = args[:intent_name].to_s
          args
        end
      end
    end
  end
end
