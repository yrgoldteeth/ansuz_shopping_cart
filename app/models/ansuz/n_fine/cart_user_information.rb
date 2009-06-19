module Ansuz
  module NFine
    class CartUserInformation < ActiveRecord::Base

      belongs_to  :carts, :class_name => "Ansuz::NFine::Cart"

    end
  end
end

