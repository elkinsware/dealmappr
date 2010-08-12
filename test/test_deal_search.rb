require 'helper'

class TestDealSearch < Test::Unit::TestCase

  def test_location_deal_search
    @ds.l = "Houston"
    
    deal_results = @ds.deals
    assert deal_results.results.size > 0
  end
  
  def test_advance_deal_search
    @ds.l = "Houston"
    @ds.q = ""
    @ds.d = 100
    @ds.si = 25
    @ds.ps = 20
    @ds.a = 1
    @ds.ed = Date.new(Time.now.year + 1, Time.now.month, Time.now.day)
    
    deal_results = @ds.deals
    assert deal_results.results.size > 0    
  end
  
  def setup
    @ds = DealMappr::Search::Deals.new
  end
  
end