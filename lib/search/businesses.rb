
module DealMappr
  module Search
    
    #
    # For more documentation on The DealMap API for Deal Searches look at: http://apiwiki.thedealmap.com/index.php/Search_Business_Listings
    #
    class Businesses < BaseSearch
      attr_accessor :l, :q, :d, :si, :ps, :a
      
      def initialize(options = {})
        super
      end
      
      def businesses
        BusinessResults.new(self.class.get(build_url).parsed_response)
      end
      
      protected
        def base_url
          "http://api.thedealmap.com/search/businesses/?"
        end
        
        def api_params
          [:l, :q, :d, :si, :ps, :a, :key]
        end    
    end

    
    class BusinessResults < BaseResults
      def initialize(xml)
        super
        @root_node = "Businesses"
        @item_node = "Business"
      end
    end  
  
  end
end