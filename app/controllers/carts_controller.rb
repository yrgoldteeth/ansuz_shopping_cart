class CartsController < ApplicationController
  unloadable # This is required if you subclass a controller provided by the base rails app
  before_filter :login_required#, :only => [:ordered, :previous]
  before_filter :load_current_cart, :only => [:show, :checkout, :index, :add, :update, :apply_coupon]
  before_filter :load_cart,  :only => [:previous]
  before_filter :load_carts, :only => [:ordered]
  before_filter :load_active_merchant_credit_card, :only => [:checkout]

  private
  def load_current_cart #for some reason, extending users with this doesn't always find their cart, but creates a new one.
    if current_user.carts.find(:first, :order=> 'id desc')
      @cart = current_user.carts.find(:first, :order => 'id desc')
      @line_items = @cart.line_items
    else
      @cart = Ansuz::NFine::Cart.create(:user_id => current_user.id)
    end
  end

  def load_carts
    @carts = current_user.carts.ordered.find(:all)
  end

  def load_cart
    @cart = current_user.carts.find(params[:id], :include => [:line_items, { :person => [:addresses] }])
  end

  def load_active_merchant_credit_card
    @active_merchant_credit_card = ActiveMerchant::Billing::CreditCard.new(
      params[:active_merchant_credit_card]
    )
    if @cart.person && @cart.person.billing_address
      @active_merchant_credit_card.first_name = @cart.person.first_name
      @active_merchant_credit_card.last_name = @cart.person.last_name
    end
    @active_merchant_credit_card.type ||= "visa"
    params[:active_merchant_credit_card] ||= { :type => 'visa' }
  end

  public
  def index
    redirect_to :action => 'show'
  end

  def show
  end

  def checkout
    @step = params[:step].to_i
    case @step
    when 5
#      handle_process_order
    when 4
      handle_confirmation_page
    when 3
      handle_alternate_shipping_address
    when 2
      handle_billing_information
    end
  end

  def ordered
  end

  def update
    case params[:form_action]
    when "Remove Selected"
    line_item_ids = params.keys.map do |key|
      if key =~ /select_([\d]+)/
        $1.to_i
      end
    end
      @line_items = Ansuz::NFine::LineItem.find line_item_ids
      @line_items.map(&:destroy)
      @cart.update_subtotal!
      flash[:notice] = "Item has been removed from cart"
      redirect_to cart_path
    when "Clear Cart"
      @cart.line_items.map(&:destroy)
      @cart.update_subtotal
      flash[:notice] = "Items have been removed from cart"
      redirect_to cart_path
    when "Update Quantity"
      params[:quantity_line_item_id].each_with_index do |line_item_id, i|
        line_item = Ansuz::NFine::LineItem.find(line_item_id)
        quantity = params[:quantity][i].to_i
        if !(quantity > 0)
          line_item.destroy
        else #check to see if the new quantity triggers a different price point on the item
          price = line_item.product.quantity_price(quantity) * 100
          line_item.quantity = quantity
          line_item.price_in_cents = price.to_i
          line_item.save
        end
      end
      flash[:notice] = "Quantity updated successfully"
      redirect_to params[:redirect_path] || cart_path
    end
  end

  def add
      product_params = params[:product]
      qty = product_params[:qty].to_i
      product_id = product_params[:id]
      if product_params[:details]
        details = product_params[:details]
      end

      if qty > 0
        product = Ansuz::NFine::Product.find(product_id, :include => [:quantity_discounts])
        price = product.quantity_price(qty)
        options = {}
        options[:price_in_cents] = (price * 100).to_i
        options[:quantity] = qty
        options[:product_id] = product_id
        options[:configuration] = details
          logger.info "Adding product: #{product.inspect}.  Quantity: #{qty}."
        @cart.add(product, options)
      end
      redirect_to :controller => 'products'
  end 


  protected
  #Create a person associated to user and cart, then show form for user to enter billing details
  def handle_billing_information #case 2
    @person = Ansuz::NFine::Person.new(:user_id => current_user.id)
    @cart.person = @person
    @cart.save
    @address = Ansuz::NFine::Address.new
    render :action => 'checkout_billing_information'
  end

  #Save the billing address from step 2
  def handle_alternate_shipping_address #case3
    @address = Ansuz::NFine::Address.new(params[:address])
    @address.address_type = "Billing"
    @address.person = @cart.person
    @address.cart = @cart
    @address.save
    #create hash of necessary person objects from billing address, update person with objects
    person_hash = {:first_name => @address.first_name, :last_name => @address.last_name, :email => @address.email, :phone_number => @address.phone_number}
    @cart.person.update_attributes(person_hash)
    #if the user wants to use the same address for shipping, create a new address associated to person and cart identical to billing but with shipping as address type
    if params["use_for_shipping"]
      @shipping_address = Ansuz::NFine::Address.new(params[:address])
      @shipping_address.address_type = "Shipping"
      @shipping_address.person = @cart.person
      @shipping_address.cart = @cart
      @shipping_address.save
      handle_confirmation_page
    else
      @shipping_address = Ansuz::NFine::Address.new
      render :action => 'checkout_alternate_shipping_address'
    end
  end

  def handle_process_order
    process_order = case RAILS_ENV
                    when 'development'
                      lambda{@cart.order!}
                    else
                      lambda{@cart.order_and(:purchase, :credit_card => @active_merchant_credit_card, :billing_address => @billing_address_hash)}
                    end
    if process_order.call
      cookies[:cart] = nil
      @step = 99
      @cart.reload
      @cart.save
      render :action => 'checkout_success'
    else
      if @cart.response && @cart.response.params
        flash.now[:error] = @cart.response.params["response_reason_text"]
      end
      render :action => 'checkout_payment'
    end
  end

  def handle_confirmation_page
    if params[:shipping_address]
      @shipping_address = Ansuz::NFine::Address.new(params[:shipping_address])
      @shipping_address.person = @cart.person
      @shipping_address.cart = @cart
      @shipping_address.save
    end
    if @cart.person
      @active_merchant_credit_card.first_name = @cart.person.first_name
      @active_merchant_credit_card.last_name = @cart.person.last_name
    end
    if @active_merchant_credit_card.valid?
      render :action => 'checkout_confirm'
    else
      render :action => 'checkout_payment'
    end
  end
end
