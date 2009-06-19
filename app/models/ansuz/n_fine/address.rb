module Ansuz
  module NFine
    class Address < ActiveRecord::Base

      belongs_to  :person, :class_name => 'Ansuz::NFine::Person'
      belongs_to  :cart, :class_name => 'Ansuz::NFine::Cart'
      validates_presence_of :line1, :city, :zip_postal, :country, :phone_number, :first_name, :last_name, :email

      def zip
        zip_postal
      end

      def to_s
        address_string=''
        [self.line1, self.line2, self.city + ', ' + self.state + ' ' + self.zip].each do |address_line| 
          address_string << address_line + "\n" unless address_line.blank?
        end
        return address_string
      end

      def state
        "#{state_province}"
      end

      def zip
        "#{zip_postal}"
      end

      def name
        "#{first_name} #{last_name}"
      end

      def escaped_line1
        if( self.line1 )
          self.line1.gsub(/&/, '&amp;')
        end
      end

      def escaped_line2
        if( self.line2 )
          self.line2.gsub(/&/, '&amp;')
        end
      end

      def escaped_line3
        if( self.line3 )
          self.line3.gsub(/&/, '&amp;')
        end
      end

    end
  end
end

