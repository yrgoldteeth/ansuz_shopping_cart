#TODO cleanup this formatting.
class CreateCarts < ActiveRecord::Migration
  def self.up
    create_table :carts do |t|
    t.integer  "user_id",             :limit => 11
    t.datetime "ordered_at"
    t.integer  "cart_transaction_id", :limit => 11
    t.decimal  "subtotal",                          :precision => 10, :scale => 2
    t.decimal  "total",                             :precision => 10, :scale => 2
    t.text     "response"
    t.string   "cookie_id"
    t.string   "shipping_method",                                                  :default => "ground",  :null => false
    t.boolean  "rush_shipping",                                                    :default => false,     :null => false
    t.text     "gift_message"
    t.decimal  "sales_tax",                         :precision => 10, :scale => 2
    t.string   "status",                                                           :default => "pending"
    t.string   "tracking_number"
    t.date     "shipped_on"
    t.string   "ship_carrier"
    t.boolean  "duplicated",                                                       :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :carts
  end
end
