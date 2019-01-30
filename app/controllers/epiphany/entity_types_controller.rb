require_dependency "epiphany/application_controller"

module Epiphany
  class EntityTypesController < ApplicationController
    def index
      @entity_types = Epiphany::EntityType.all
    end
  end
end
