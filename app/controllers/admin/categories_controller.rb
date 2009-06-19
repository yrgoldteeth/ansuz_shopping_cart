class Admin::CategoriesController < Admin::BaseController
  unloadable # This is required if you subclass a controller provided by the base rails app
  layout 'admin'
  before_filter :load_category,     :only => [:show, :edit, :update, :destroy] 
  before_filter :load_new_category, :only => [:new, :create]
  before_filter :load_categories,    :only => [:index]

  protected
  def load_category
    @category = Ansuz::NFine::Category.find(params[:id], :include => [:products])
  end

  def load_new_category
    @category = Ansuz::NFine::Category.new(params[:category])
  end

  def load_categories
    @categories = Ansuz::NFine::Category.find(:all, :order => 'created_at DESC')
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
    if @category.save
      flash[:notice] = 'Category was successfully created.'
      redirect_to admin_category_path(@category) 
    else
      flash.now[:error] = "There was a problem creating the category.  Please try again."
      render :action => "new"
    end
  end

  def update
    if @category.update_attributes(params[:category])
      flash[:notice] = 'Category was successfully updated.'
      redirect_to admin_category_path(@category) 
    else
      flash.now[:error] = "There was a problem updating the category.  Please try again."
      render :action => "edit"
    end
  end

  def destroy
    @category.destroy
    flash[:notice] = 'Category was deleted.'
    redirect_to admin_categories_path
  end
end
