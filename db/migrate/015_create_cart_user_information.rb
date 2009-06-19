class CreateCartUserInformation < ActiveRecord::Migration
  def self.up
    create_table :cart_user_informations do |t| 
      t.string   "name"
      t.string   "phone_number"
      t.string   "email_address"
      t.string   "shipping_line1"
      t.string   "shipping_line2"
      t.string   "shipping_city"
      t.string   "shipping_state_province"
      t.string   "shipping_zip_postal"
      t.string   "shipping_country"
      t.string   "billing_line1"
      t.string   "billing_line2"
      t.string   "billing_city"
      t.string   "billing_state_province"
      t.string   "billing_zip_postal"
      t.string   "billing_country"
      t.timestamps
    end
  end

  def self.down
    drop_table :cart_user_informations
  end
end
