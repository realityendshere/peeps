class PhoneNumber
  include Mongoid::Document
  include Mongoid::Timestamps

  has_one :contact

  field :name,         type: String
  field :phone_number, type: String

end
