
module DealMappr
  module Search
  
    #
    # For more documentation on The DealMap API for Deal Searches look at: http://apiwiki.thedealmap.com/index.php/Search_Deals
    #
    class Deals < BaseSearch   
      attr_accessor :l, :q, :d, :si, :ps, :a, :c, :ed
      
      def initialize(options = {})
        super
      end
      
      def deals
        DealResults.new(self.class.get(build_url).parsed_response)
      end
      
      protected
        def base_url
          "http://api.thedealmap.com/search/deals/?"
        end
        
        def ed_for_params
          ed.strftime("%Y-%m-%d") if ed.is_a?(Date)
        end
        
        def api_params
          [:l, :q, :d, :si, :ps, :a, :c, :ed, :key]
        end
    end
   
    class DealResults < BaseResults
      def initialize(xml)
        super
        @root_node = "Deals"
        @item_node = "Deal"
      end
    end 
    
  end
end