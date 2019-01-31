require "active_support/core_ext/hash/indifferent_access"
require_relative 'tokenizer_schema'

module Epiphany
  class IntentType
    attr_accessor :type, :optional_entities, :required_entities, :keywords_boost

    def initialize(filepath, args)
      @type = args["type"] || args[:type] || filepath.match(/(\w+)(.json)/i)[0].gsub('.json','')
      @required_entities = args['required_entities'] || args[:required_entities] || []
      @optional_entities = args['optional_entities'] || args[:optional_entities] || []
      @keywords_boost = args[:keywords_boost] || args['keywords_boost'] || []
    end
  end
end