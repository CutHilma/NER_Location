class InstagramScraperController < ApplicationController
  require 'httparty'
  require 'nokogiri'

  def index
  end

  def scrape
    url = params[:url]

    begin
      response = HTTParty.get(url, headers: {
        "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
      })
      parsed_page = Nokogiri::HTML(response.body)

      meta_tag = parsed_page.css('meta[property="og:description"]').first
      @caption = meta_tag['content'] if meta_tag
    rescue => e
      @error = "Terjadi kesalahan: #{e.message}"
    end

    render :index
  end
end
