class Contact
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :phone_numbers

  ### Validations
  validates :name_first, presence: true
  validates :name_last, presence: true

  field :name_first,    type: String
  field :name_last,     type: String
  field :email,         type: String
  field :twitter,       type: String

end
