# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

class Crawler
  class << self
    def crawl_internal_links(domain)
      page = Nokogiri::HTML(open(URI.encode(domain)))

      page.search('a').map do |link|
        link['href'] if valid_internal_link(link['href'])
      end.compact

    rescue OpenURI::HTTPError
      puts "Couldn't retrieve links from #{domain}"
    end

    private

    def valid_internal_link(link)
      link.start_with?('/') &&
        %r{\/\b[a-zA-Z]*\b}.match?(link)
    end
  end
end
