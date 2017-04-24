class Product < ApplicationRecord
  belongs_to :merchant
  has_many :users, through: :userlikeitems
  has_many :userlikeitems, :dependent => :destroy
end
