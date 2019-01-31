module Epiphany
  class Entity
    attr_accessor :type, :phrase, :metadata

    def initialize(type, phrase, **metadata)
      @type = type
      @phrase = phrase
      @metadata = metadata
    end
  end
end
