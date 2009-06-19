class AddCartIdToCartUserInformation < ActiveRecord::Migration
  def self.up
    add_column :cart_user_informations, :cart_id, :integer
  end

  def self.down
    remove_column :cart_user_informations, :cart_id
  end
end

