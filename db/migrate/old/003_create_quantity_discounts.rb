class CreateQuantityDiscounts < ActiveRecord::Migration
  def self.up
    create_table :quantity_discounts do |t|
      t.integer :product_id
      t.float :price
      t.integer :low_quantity
      t.integer :high_quantity

      t.timestamps
    end
  end

  def self.down
    drop_table :quantity_discounts
  end
end
