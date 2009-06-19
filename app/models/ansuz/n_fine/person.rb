module Ansuz
  module NFine
    class Person < ActiveRecord::Base

      belongs_to  :cart, :class_name => 'Ansuz::NFine::Cart'
      belongs_to  :user
      has_many  :addresses, :class_name => 'Ansuz::NFine::Address', :order => 'id DESC'

      def billing_address
        addresses.find_by_address_type('Billing', :order => 'id DESC')
      end

      def shipping_address
        addresses.find_by_address_type('Shipping', :order => 'id DESC')
      end

      def name
        "#{first_name} #{last_name}"
      end

    end
  end
end

