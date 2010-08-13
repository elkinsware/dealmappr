#
# Bit Masking comes from http://railscasts.com/episodes/189-embedded-association
# For photo_content -- http://stackoverflow.com/questions/1547008/how-to-encode-media-in-base64-given-url-in-ruby
#
# This implements Deals API for getting details about a deal and submitting deals.
#
# EXPERIMENTAL: Submitting Deals is experimental.  This needs to be tested.  I am wondering if there is a Test Environment (or Sandbox) for testing this.
#
module DealMappr
  module Deals
  
    class Deal
      include HTTParty
      format :xml
      
      BASE_URL = "http://api.thedealmap.com/deals"
      
      CURRENCIES = ['Unknown', 'USD', 'GBP', 'EUR']
      
      DEAL_UNIT = ['Unknown', 'Price', 'Percentage']
      
      DEAL_CAPABILITIES = [
        'Unknown', 'Favorite',
        'HasTransaction',
        'Featured',
        'Exclusive',
        'FiftyPercentOrMore',
        'CanBePrinted',
        'Affilate'
      ]
      
      DEAL_TYPES = [
        'Undefined',
        'GiftCertificate',
        'BOGO',
        'PrintableCoupon',
        'GroupBuy',
        'DailyDeal',
        'FreeDeal'
      ]
      
      CENTERED_ACTIVITIES = [
        'Kids',
        'Group',
        'Romantic',
        'Casual',
        'Fun',
        'Late-Night',
        'Outdoor'
      ]
      
      REQUIRED_FIELDS = [
        :title, :expiration_date, :added_by, :country, :city, :state, :business_name,
        :street_address
      ]
      
      SUBMISSION_FIELDS = [
        :id, :first_name, :last_name, :url, :is_exclusive, :is_owner, :social_network_id, 
        :longitude, :latitude, :photo_type, :photo_content, :tags, :category, :styles
      ].concat(REQUIRED_FIELDS)
      
      VALIDATE_VALUES = {
        :is_exclusive => [true, false],
        :is_owner => [true, false],
      }
      
      ALWAYS_SEND_FALSE = [ :daily_deals_email_ok ]
      
      attr_accessor :activity, :added_by, :additional_discount_coupon_code,
                          :additional_discount_coupon_effective_time,
                          :additional_discount_coupon_expiration_time,
                          :additional_discount_deal_unit, :additional_discounted_value,
                          :address_line, :affiliation, :bdescription, :business_id,
                          :business_name, :capability, :category, :city, :country,
                          :currency, :deal_source, :deal_type, :deal_unit,
                          :description, :discounted_value, :effective_time, :expiration_time,
                          :face_value, :id, :icon_url, :image_url, :keywords, :latitude,
                          :longitude, :more_info_link, :phone, :state, :tags, :terms,
                          :title, :tracking_url, :transaction_url, :you_save, :zip_code
      
      attr_accessor :social_network_id, :photo_type, :photo_content, :first_name, :last_name
      
      def initialize(key, attributes = {})
        @styles_mask = 0
        @errors = []
        @key = key
        
        attributes.each do |attribute_name, value|          
          send("#{underscore(attribute_name)}=".to_sym, value) if respond_to?(underscore(attribute_name))
        end
      end
      
      def deal_types
        DEAL_TYPES.reject { |r| ((deal_type || 0) & 2**DEAL_TYPES.index(r)).zero? }
      end
      
      def deal_types=(deal_types)
        self.deal_type = (deal_types & DEAL_TYPES).map { |r| 2**DEAL_TYPES.index(r) }.sum
      end
      
      def deal_type_symbols
        deal_types.map(&:to_sym)
      end
      
      def capabilities
        DEAL_CAPABILITIES.reject { |r| ((capability || 0) & 2**DEAL_CAPABILITIES.index(r)).zero? }
      end
      
      def capabilities=(capabilities)
        self.capability = (capabilities & DEAL_CAPABILITIES).map { |r| 2**DEAL_CAPABILITIES.index(r) }.sum
      end
      
      def capability_symbols
        capabilities.map(&:to_sym)
      end
      
      def styles
        CENTERED_ACTIVITIES.reject { |r| ((@styles_mask || 0) & 2**CENTERED_ACTIVITIES.index(r)).zero? }
      end
      
      def styles=(styles)
        @styles_mask = (styles & CENTERED_ACTIVITIES).map { |r| 2**CENTERED_ACTIVITIES.index(r) }.sum
      end
      
      def style_symbols
        styles.map(&:to_sym)
      end

      def photo=(file_path)
        photo_content = Base64.encode64(open(file_path) { |io| io.read })
      end
      
      def errors?
        @errors = []
        check_required_fields_are_filled_in
        check_that_values_are_valid
      end
      
      def errors
        errors?
      end
        
      def to_xml
        @xml ||= build_xml
      end        
      
      #def save
      #  return false if errors?
      #  self.class.post("#{BASE_URL}/", :key => @key, :xml => to_xml)
      #end
      
      def self.lookup(id, key = "")
        if parsed_response = get("#{BASE_URL}/#{id}/?#{add_key_param(key)}").parsed_response
          Deal.new(key, parsed_response["Deal"])
        end
      end
    
      protected
        def self.add_key_param(key)
          "key=#{key}" unless key.blank?
        end
        
        #From ActiveSupport
        def underscore(camel_cased_word)
          camel_cased_word.to_s.gsub(/::/, '/').
            gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
            gsub(/([a-z\d])([A-Z])/,'\1_\2').
            tr("-", "_").
            downcase
        end
        
        #From ActiveSupport
        def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
          if first_letter_in_uppercase
            lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
          else
            lower_case_and_underscored_word.first.downcase + camelize(lower_case_and_underscored_word)[1..-1]
          end
       end

        def check_required_fields_are_filled_in
          REQUIRED_FIELDS.each do |field|
            @errors << "#{field} is not filled in.  Required." if send(field).blank?
          end
        end
        
        def check_that_values_are_valid
          VALIDATE_VALUES.each do |field, allowed_values|
            unless allowed_values.include?(send(field))
              @errors << "invalid value for #{field}.  Currently is #{send(field)} but should be one of the following #{allowed_values.join(", ")}." 
            end
          end
        end

        def build_xml
          builder = Builder::XmlMarkup.new
          builder.instruct!(:xml, :version=>"1.0", :encoding=>"UTF-8")
          builder.AddDealRequest("xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",  "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema") do
            SUBMISSION_FIELDS.each do |field|
              if field == :id
                builder.ID(id)
              else
                builder.tag!(camelize("#{field}").to_sym , send(field))
              end
            end
          end          
        end
    end
    
  end
end