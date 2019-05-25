# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

class SiteMapper
  attr_reader :domain
  attr_accessor :links

  def initialize(domain)
    @domain = domain
    @links = [domain]
  end

  def retrieve_links
    page = Nokogiri::HTML(open(domain))

    page.search('a').map do |link|
      links << link['href'] if valid_link(link['href'])
    end.compact

    links
  end

  def valid_link(link)
    link.start_with?('/') &&
      %r{\/\b[a-zA-Z]*\b}.match?(link)
  end
end
