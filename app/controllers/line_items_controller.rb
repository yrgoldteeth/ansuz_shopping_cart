class LineItemsController < ApplicationController
  unloadable # This is required if you subclass a controller provided by the base rails app
  before_filter :login_required
  before_filter :get_line_item, :only => [:destroy]

  protected
  def get_line_item
    @line_item = current_user.current_cart.line_items.find(params[:id])
  end

  public
  def destroy
    cart = @line_item.cart
    @line_item.destroy
    cart.save
    flash[:notice] = "Line item was removed from cart."
    redirect_to cart_path
  end
end

