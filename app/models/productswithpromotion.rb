class Productswithpromotion < ApplicationRecord
  belongs_to :promotion
  belongs_to :product
end
