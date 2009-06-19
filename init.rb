#Register the admin menu instances for managing products and creating a new product.
require 'extend_users_with_cart_information'
Ansuz::PluginManagerInstance.register_admin_menu_entry('Manage', 'Products', '/admin/products')
Ansuz::PluginManagerInstance.register_admin_menu_entry('Manage', 'Product Categories', '/admin/categories')
