class HabtmForCategories < ActiveRecord::Migration
  def self.up
    create_table "categories_products", :id => false do |t|
      t.column "category_id", :integer
      t.column "product_id", :integer
    end
    add_index "categories_products", "category_id"
    add_index "categories_products", "product_id"

    remove_column :products, :category_id 
  end

  def self.down
    add_column :products, :category_id 

    remove_index "categories_products", :column => "product_id"
    remove_index "categories_products", :column => "category_id"
    drop_table "categories_products"
  end
end
