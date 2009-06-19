module Ansuz
  module NFine
    class QuantityDiscount < ActiveRecord::Base
      belongs_to  :product, :class_name => 'Ansuz::NFine::Product'
      validates_presence_of  :price, :low_quantity, :high_quantity, :product_id

      def quantity_range
        self.low_quantity.to_s + " - " + self.high_quantity.to_s
      end

    end
  end
end
