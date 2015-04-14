require 'jsonapi/resource_controller'

module JSONAPI
  class ResourceController

    def create_operations_processor
      JSONAPI::OperationsProcessor.new
    end

  end
end
