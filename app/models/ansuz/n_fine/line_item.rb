module Ansuz
  module NFine
    class LineItem < ActiveRecord::Base

      belongs_to  :cart, :class_name => 'Ansuz::NFine::Cart'
      belongs_to  :product, :class_name => 'Ansuz::NFine::Product'
      before_save  :calculate_total
      after_save  :save_cart
      validates_presence_of  :amount
      validates_presence_of  :cart_id
      validates_presence_of  :quantity
      
      def calculate_total
        self.amount = (price_in_cents * quantity) / BigDecimal('100.0')
      end

      def price
        price_in_cents / 100.0
      end

      def save_cart
        cart.save
      end

      

    end
  end
end

