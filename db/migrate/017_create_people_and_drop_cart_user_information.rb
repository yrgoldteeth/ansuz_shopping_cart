class CreatePeopleAndDropCartUserInformation < ActiveRecord::Migration
  def self.up
    drop_table :cart_user_informations
    create_table :people do |t|
      t.string  "first_name"
      t.string  "last_name"
      t.string  "title"
      t.string  "phone_number"
      t.string  "extension"
      t.string  "email"
      t.integer "cart_id",      :limit => 11
      t.integer "user_id",      :limit => 11
      t.timestamps
    end
    add_index "people", ["last_name"], :name => "index_people_on_last_name"
    add_index "people", ["cart_id"], :name => "index_people_on_cart_id"
  end

  def self.down
    remove_index "people", :name => "index_people_on_cart_id"
    remove_index "people", :name => "index_people_on_last_name"
    drop_table :people
  end
end



