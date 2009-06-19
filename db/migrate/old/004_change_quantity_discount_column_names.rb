class ChangeQuantityDiscountColumnNames < ActiveRecord::Migration
  def self.up
    rename_column :products, :quantity_discount, :has_quantity_discount
  end

  def self.down
    rename_column :products, :has_quantity_discount, :quantity_discount
  end
end
