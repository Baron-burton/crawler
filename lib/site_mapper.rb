# frozen_string_literal: true

class SiteMapper
  attr_reader :domain
  attr_accessor :links

  def initialize(domain)
    @domain = domain
    @links = [domain]
  end

  def retrieve_internal_links
    links + Crawler.crawl_internal_links(domain)
  end
end
