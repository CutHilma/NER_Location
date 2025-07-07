require "test_helper"

class InstagramScraperControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get instagram_scraper_index_url
    assert_response :success
  end

  test "should get scrape" do
    get instagram_scraper_scrape_url
    assert_response :success
  end
end
