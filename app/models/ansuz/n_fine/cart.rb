require 'aasm'
module Ansuz
  module NFine
    class Cart < ActiveRecord::Base

      include AASM

      ORDER_NUMBER_OFFSET = 24998
      CREDIT_CARD_TYPES   = ["Visa", "Mastercard", "Discover", "American Express"]
      MONTHS              = [
        ["January", "01"], ["February", "02"], ["March", "03"],
        ["April", "04"], ["May", "05"], ["June", "06"], ["July", "07"],
        ["August", "08"], ["September", "09"], ["October", "10"],
        ["November", "11"], ["December", "12"]
      ]
      YEARS               = (2008..2020)

      aasm_column :status
      aasm_initial_state :pending

      aasm_state :pending
      aasm_state :shipped
      aasm_state :canceled

      aasm_event :ship do
        transitions :to => :shipped, :from => [:pending]
      end

      aasm_event :duplicate do
        # aasm isn't firing the on_transition for cancel!, so we need to call zero_out_totals to clear the values for the canceled order
        transitions :from => [:pending, :shipped], :on_transition => lambda{|order| order.reissue! }
      end

      aasm_event :cancel do
        transitions :to => :canceled, :from => [:pending, :shipped], :on_transition => lambda{|order| order.zero_out_totals! }
      end


      belongs_to  :user
      has_one  :person, :class_name => 'Ansuz::NFine::Person'
      has_many  :line_items,  :class_name => 'Ansuz::NFine::LineItem', :dependent => :destroy
      has_many  :products, :through => :line_items

      before_save  :update_subtotal, :update_total
  
      named_scope   :ordered, :conditions => [ 'ordered_at IS NOT NULL' ], :order => [ 'ordered_at DESC' ]
      named_scope   :unordered, :conditions => [ 'ordered_at IS NULL' ], :order => [ 'ordered_at DESC' ]
      serialize     :response
      attr_accessor :gateway, :duplicating

      def visible_status
        if( self.status == "pending" )
          "In Process"
        else
          self.status
        end
      end

      def ordered?
        ordered_at ? true : false
      end

      def add product, options = {}
        options = { :quantity => 1 }.merge(options)
        options[:cart_id] = self.id
        li = Ansuz::NFine::LineItem.new(options)
        li.product = product
        li.calculate_total
        li.save
      end

      def total_in_cents
        (total * 100).to_i if total
      end

      def calculated_subtotal
        calc = line_items.inject(0.0) do |sum, li|
          sum += li.amount
        end
        calc.nil? ? 0.0.to_d : calc
      end

      def update_subtotal
        self.subtotal = calculated_subtotal
      end

      def update_subtotal!
        update_subtotal
        save
      end

      def calculated_total
        begin
          subtotal + shipping_rate + rush_rate + sales_tax
        rescue
          subtotal
        end
      end

      def update_total
        self.total = calculated_total if (status != 'canceled')
      end

      def update_total!
        update_total
        save
      end
      
#      def proper_person
#        if self.user
#          self.user.person
#        else
#          self.person
#        end
#      end

      def gateway
        if @gateway
          @gateway
        else
          @gateway = BILLING_GATEWAY
          def @gateway.get_post_data action, parameters={}
            post_data(action, parameters)
          end
          @gateway
        end
      end

      def order!
        self.ordered_at = Time.now
        transaction do
          save!
        end
        #    UserMailer.deliver_cart_order_notification(self)
        #    AdminMailer.deliver_cart_order_notification(self)
      end

        def order_and action, options={}
          if total_in_cents > 0
            credit_card     = options[:credit_card]
            billing_address = options[:billing_address]
            raise "You must pass in an ActiveMerchant credit card" unless credit_card
            raise "You must pass in a billing address" unless billing_address
            logger.info "Billing address was: " + billing_address.inspect

            transaction_options = {
              :address         => billing_address,
              :billing_address => billing_address,
              :order_id        => invoice_number
            }

            if credit_card.valid?
              logger.info("valid credit card")
              logger.info "Charging credit card for #{total_in_cents} cents."
              self.response = gateway.send(action, total_in_cents, credit_card, transaction_options)
              save
              if response && response.success?
                order!
              end
              response
            else
              logger.info("invalid credit card")
              credit_card.errors.each do |err|
                err[1].each do |err1|
                  self.errors.add(err[0], err1)
                end
              end
            end
            if response
              response.success?
            else
              false
            end
          else
            true
          end
        end

        def billing_address
          if self.person
            self.person.addresses.find_by_address_type('Billing', :order => 'id DESC')
          end
        end

        def email_address
          # Get the email address on the billing address
          self.billing_address.email if self.billing_address
        end

        def shipping_address
          if self.person
            self.person.addresses.find_by_address_type('Shipping', :order => 'id DESC')
          end
        end

      end
    end
  end
