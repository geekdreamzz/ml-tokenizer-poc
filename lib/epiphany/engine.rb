require 'rails'

module Epiphany
  class Engine < ::Rails::Engine
    isolate_namespace Epiphany
    config.eager_load = true
  end
end
