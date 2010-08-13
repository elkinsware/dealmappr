begin
  require "httparty"
rescue LoadError
  require "rubygems"
  require "httparty"
end

require 'base64'
require 'builder'

require 'search/base'
require 'search/deals'
require 'search/businesses'

require 'deals/deal'