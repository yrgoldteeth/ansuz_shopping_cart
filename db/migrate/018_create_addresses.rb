class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table  :addresses do |t|
      t.string  "line1"
      t.string  "line2"
      t.string  "line3"
      t.string  "city"
      t.string  "state_province"
      t.string  "zip_postal"
      t.string  "country"
      t.string  "address_type"
      t.integer "person_id",      :limit => 11
      t.integer "cart_id",        :limit => 11
      t.string  "first_name"
      t.string  "last_name"
      t.string  "phone_number"
      t.string  "extension"
      t.string  "email"
      t.string  "company_name"
      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end


