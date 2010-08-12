begin
  require "httparty"
rescue LoadError
  require "rubygems"
  require "httparty"
end

module DealMappr
  class BaseSearch
    include HTTParty
    format :xml
    
    def initialize(options = {})
      @api_key = options.delete(:api_key)
      
      #set any defaults you want for values
      options.each { |k,v| send("#{k}=".to_sym, v) if respond_to?(k) }
    end    
    
    protected
      def key
        @api_key
      end    
      
      def build_url
        params = api_params.collect do |param|
          build_param(param)
        end
        
        "#{base_url}#{params.join("&")}"
      end

      def build_param(param)
        if respond_to?("#{param}_for_params")
          "#{param}=#{send("#{param}_for_params".to_sym)}" if send("#{param}_for_params".to_sym)
        else
          "#{param}=#{send(param)}" if send(param)
        end
      end
  end
  
  #
  # For more documentation on The DealMap API for Deal Searches look at: http://apiwiki.thedealmap.com/index.php/Search_Deals
  #
  class DealSearch < BaseSearch   
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
  
  #
  # For more documentation on The DealMap API for Deal Searches look at: http://apiwiki.thedealmap.com/index.php/Search_Business_Listings
  #
  class BusinessSearch < BaseSearch
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
  
  class BaseResults
    def initialize(xml)
      @xml = xml
    end
    
    def raw
      @xml
    end
    
    def message
      @message ||= @xml[@root_node]["Message"]
    end    
    
    def results
      @results ||= @xml[@root_node]["Results"][@item_node]
    end    
  end
  
  class BusinessResults < BaseResults
    def initialize(xml)
      super
      @root_node = "Businesses"
      @item_node = "Business"
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