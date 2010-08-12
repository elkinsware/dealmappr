

module DealMappr
  module Search
  
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
    
  end
end