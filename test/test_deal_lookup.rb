require 'helper'

class TestDealLookup < Test::Unit::TestCase
  
  def setup
    @search = DealMappr::Search::Deals.new
    @search.l = "Houston"
    @deal_results = @search.deals
    @deal_found_in_search = @deal_results.results.detect {|d| not d["ID"].blank? }
    @deal_id = @deal_found_in_search["ID"]
  end
  
  def test_lookup
    @deal = DealMappr::Deals::Deal.lookup(@deal_id)
    
    assert_equal @deal_id, @deal.id
    assert_equal @deal_found_in_search["Activity"], @deal.activity
    assert_equal @deal_found_in_search["BusinessName"], @deal.business_name
    assert_equal @deal_found_in_search["Latitude"], @deal.latitude
    assert_equal @deal_found_in_search["Longitude"], @deal.longitude
    assert_equal @deal_found_in_search["ExpirationTime"], @deal.expiration_time
    assert_equal @deal_found_in_search["DealSource"], @deal.deal_source
  end
  
  def test_lookup_invalid_id
    @deal = DealMappr::Deals::Deal.lookup("BAD_DEAL_ID")
    assert_nil @deal
  end
  
end