class Admin::ProductsController < Admin::BaseController
  unloadable # This is required if you subclass a controller provided by the base rails app
  layout 'admin'
  before_filter :load_product,     :only => [:show, :edit, :update, :destroy]
  before_filter :load_new_product, :only => [:new, :create]
  before_filter :load_products,    :only => [:index]

  protected
  def load_product
    @product = Ansuz::NFine::Product.find(params[:id], :include => [:quantity_discounts])
    @categories = Ansuz::NFine::Category.find(:all)
  end

  def load_new_product
    @product = Ansuz::NFine::Product.new(params[:product])
    @categories = Ansuz::NFine::Category.find(:all)
  end

  def load_products
#    @products = Ansuz::NFine::Product.find(:all, :order => 'created_at DESC')
    @categories = Ansuz::NFine::Category.find(:all, :include => [:products])
  end

  public
  def index
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
      if @product.save
        flash[:notice] = 'Product was successfully created.'
        redirect_to admin_products_path
      else
        flash.now[:error] = "There was a problem creating the Product.  Please try again."
        render :action => "new" 
      end
  end

  def update
      if @product.update_attributes(params[:product])
        flash[:notice] = 'Product was successfully updated.'
        redirect_to admin_products_path
      else
        flash.now[:error] = "There was a problem updating the Product.  Please Try again."
        render :action => 'edit'
      end
  end

  def destroy
    @product.destroy
    flash[:notice] = "Product was deleted."
    redirect_to admin_products_path 
  end

end
