#require 'active_support/concern'

module Epiphany
  class Tokenizer
    module Analyzer
      extend ::ActiveSupport::Concern

      class_methods do
        def analyzer(**args)
          @priority = args[:priority]
          @callback_method_names  = args[:callback_method_names] || []
        end

        def priority
          @priority || 1
        end

        def callback_method_names
          @callback_method_names ||= []
        end
      end
    end
  end
end