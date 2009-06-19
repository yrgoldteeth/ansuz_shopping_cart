class AddAmountToLineItems < ActiveRecord::Migration
  def self.up
    add_column :line_items, :amount, :decimal, :precision => 10, :scale => 2
  end

  def self.down
    remove_column :line_items, :amount
  end
end

