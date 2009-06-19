class RemoveHasQuantityBooleanFromProduct < ActiveRecord::Migration
  def self.up
    remove_column :products, :has_quantity_discount
  end

  def self.down
    add_column :products, :has_quantity_discount, :boolean
  end
end
