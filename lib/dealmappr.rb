begin
  require "httparty"
rescue LoadError
  require "rubygems"
  require "httparty"
end

require 'search/base'
require 'search/deals'
require 'search/businesses'