require 'jsonapi/resource'

class ApiResource < JSONAPI::Resource

  attribute :id

  class << self

    def verify_key(key, context = nil)
      key && String(key)
    end

  end

end
