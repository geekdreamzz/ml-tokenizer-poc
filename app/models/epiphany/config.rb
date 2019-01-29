module Epiphany
  class Config
    class << self

      def configure
        @settings = yield settings
      end

      def settings
        @settings ||= Struct.new(:proxy, :proxy_port, :analyzers_dir, :custom_analyzers) do
          def http_proxy
            "http://#{proxy}:#{proxy_port}"
          end

          def has_proxy?
            !!proxy
          end
        end.new
      end

      def analyzers_dir
        settings.analyzers_dir || File.join(Dir.pwd, 'app', 'models', 'epiphany' ,'analyzers', '*.rb')
      end

      def http_proxy
        settings.http_proxy
      end

      def has_proxy?
        settings.has_proxy?
      end

      def custom_analyzers
        settings.custom_analyzers = [] unless settings.custom_analyzers
        settings.custom_analyzers
      end

      def phrase_token_analyzers
        Dir[analyzers_dir].map do |filename|
          require "#{filename}"
          class_name = filename.split('/').last.split('.').first.split('_').map(&:capitalize).join
          validate_analyzer Object.const_get(class_name)
        end
      end

      def validate_analyzer(analyzer)
        valid = [
            analyzer.respond_to?(:analyzer),
            analyzer.respond_to?(:priority),
            analyzer.respond_to?(:callback_method_names)
        ].all?
        raise ArgumentError.new("#{analyzer} must be a module that includes Phrase::Tokenizer::Analyzer") unless valid
        analyzer
      end
    end
  end
end
