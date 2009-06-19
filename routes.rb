namespace :admin do |admin|
  admin.resources :products, :has_many => [:quantity_discounts]
  admin.resources :categories
#  admin.resources :quantity_discounts, :belongs_to => [:products]
end
resources :products
resource :cart, :member => [:add]
