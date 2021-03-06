class CreateLineItems < ActiveRecord::Migration
  def self.up
    create_table :line_items do |t| 
      t.integer  "cart_id"
      t.integer  "product_id",          :limit => 11
      t.integer  "quantity",            :limit => 11
      t.text     "configuration"
      t.string   "descriptive_text"
      t.integer  "price_in_cents",      :limit => 11
      t.timestamps
    end
  end

  def self.down
    drop_table :line_items
  end
end
