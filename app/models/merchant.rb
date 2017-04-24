class Merchant < ApplicationRecord
  has_many :products, :dependent => :destroy
  has_many :users, through: :userlikeshops
  has_many :userlikeshops, :dependent=>:destroy
end
