require_relative 'config'

module Epiphany
  class Tokenizer
    class Token
      attr_reader :parent_tokenizer, :phrase, :fragments

      def initialize(parent_tokenizer, phrase, fragments, **args)
        @parent_tokenizer = parent_tokenizer
        @phrase = phrase
        @fragments = fragments
        validate_args
        load_analyzers!
      end

      def analyzers
        @analyzers.sort_by!{|a| a.priority }.reverse!
      end

      def load_analyzers!
        @analyzers ||= Epiphany::Config.phrase_token_analyzers.map do |analyzer|
          self.class.include analyzer
          analyzer
        end
      end

      def execute_analysis
        @analysis ||= analyzers.each do |analysis|
          analysis.callback_method_names.each do |method_name|
            public_send(method_name) rescue binding.pry
          end
        end
      end

      def custom_analyzers
        @custom_analyzers ||= @parent_tokenizer.class.get_custom_analyzers
      end

      def validate_args
        raise ArgumentError.new("Parent Tokenizer must be of class - Phrase::Tokenizer") unless parent_tokenizer.is_a? Epiphany::Tokenizer
        raise ArgumentError.new("Phrase must be of class - String") unless phrase.is_a? String
      end
    end
  end
end
