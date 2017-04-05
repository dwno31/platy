class Merchant < ApplicationRecord
  has_many :products, :dependent => :destroy
end
