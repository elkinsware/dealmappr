require 'helper'

class TestBusinessSearch < Test::Unit::TestCase

  def test_location_deal_search
    @search.l = "Houston"
    
    business_results = @search.businesses
    assert business_results.results.size > 0
  end
  
  def test_advance_deal_search
    @search.l = "Houston"
    @search.q = ""
    @search.d = 100
    @search.si = 25
    @search.ps = 20
    @search.a = 1
    
    business_results = @search.businesses
    assert business_results.results.size > 0    
  end
  
  def setup
    @search = DealMappr::Search::Businesses.new
  end
  
end