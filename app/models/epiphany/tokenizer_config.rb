module Epiphany
  class Tokenizer
    class Config
      class << self
        def phrase_token_analyzers
          Dir[File.join(Epiphany::Engine.root, 'analyzers', '*.rb')].map do |filename|
            require "#{filename}"
            class_name = filename.split('/').last.split('.').first.split('_').map(&:capitalize).join
            validate_analyzer Object.const_get(class_name)
          end
        end

        def validate_analyzer(analyzer)
          valid = [
            analyzer.respond_to?(:analyze),
            analyzer.respond_to?(:priority),
            analyzer.respond_to?(:callback_method_names)
          ].all?
          raise ArgumentError.new("#{analyzer} must be a module that includes Phrase::Tokenizer::Analyzer") unless valid
          analyzer
        end
      end
    end
  end
end
