module Ansuz
  module NFine
    class Product < ActiveRecord::Base
      belongs_to :category, :class_name => 'Ansuz::NFine::Category'
      has_many  :quantity_discounts, :class_name => 'Ansuz::NFine::QuantityDiscount', :dependent => :destroy
      has_attached_file  :image
      attr_accessor :qty, :details

      #creates a range for the low and high end of product's existing quantity discounts
      def existing_discount_quantity_range
        product_quantity_discounts = self.quantity_discounts
        minimum_quantity = []
        maximum_quantity = []
        product_quantity_discounts.each do |q|
          minimum_quantity << q.low_quantity
          maximum_quantity << q.high_quantity
        end
        return minimum_quantity.sort.first..maximum_quantity.sort.last
      end
      
      #returns quantity range for 1 to the minimum discount quantity - 1
      def unit_price_quantity_range
        top_quantity = existing_discount_quantity_range.min - 1
        return '1 - ' + top_quantity.to_s
      end

      #returns product's price for a given quantity.  
      def quantity_price (quantity)
        if !self.quantity_discounts.empty? && self.existing_discount_quantity_range.min < quantity && self.existing_discount_quantity_range.max > quantity
          self.quantity_discounts.each do |q|
            quantity_range = q.low_quantity..q.high_quantity
            if quantity_range.include?(quantity)
              return q.price
            end
          end
        elsif !self.quantity_discounts.empty? && self.existing_discount_quantity_range.max < quantity #if quantity is greater than max discount_qty_range, return maximum_discount_price 
          return self.maximum_discount_price
        else #if the quantity is less than the minimum of the existing_discount_quantity_range, return unit price.
          return self.price
        end
      end

      #returns quantity price of existing_discount_quantity_range.max 
      def maximum_discount_price
       return self.quantity_price(self.existing_discount_quantity_range.max)
      end

    end
  end
end
