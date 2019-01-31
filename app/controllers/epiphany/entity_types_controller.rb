require_dependency "epiphany/application_controller"

module Epiphany
  class EntityTypesController < ApplicationController
    def index
      @entity_types = Epiphany::EntityType.all
    end

    def create
      Epiphany::Tokenizer::Cache.set_entity_type(entity_type_params['entity-type-name']) do
        {
          name: entity_type_params['entity-type-name'],
          validation_type: 'text_match',
          match_phrases: Hash[entity_type_params['key_phrases'].split(',').map do |phrase|
            [phrase.strip, {}]
          end]
        }
      end
      flash[:notice] = "Entity Type Added."
      @entity_types = Epiphany::EntityType.all
      render 'index'
    end

    def entity_type_params
      params.permit('entity-type-name', 'key_phrases')
    end
  end
end
