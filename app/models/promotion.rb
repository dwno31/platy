class Promotion < ApplicationRecord
  has_many :productswithpromotions
  has_many :products, through: :productswithpromotions,:dependent => :destroy
end
