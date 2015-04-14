require 'jsonapi/resource'

class PhoneNumberResource < ApiResource
  attributes :name, :phone_number
  has_one :contact

  filter :contact
end
