# frozen_string_literal: true

require 'nokogiri'
require 'faraday'
require 'URI'

class Crawler
  TIMEOUT = 0.5
  BAD_HTTP_STATUSES = [500, 404, 302].freeze

  attr_reader :base_domain

  def initialize(starting_point)
    raise 'Please provide a domain to crawl' if starting_point.nil?

    @base_domain = extract_base_url(starting_point)
  end

  def crawl_internal_links(domain)
    res = response(domain)

    return nil if BAD_HTTP_STATUSES.include? res.status

    page = Nokogiri::HTML(res.body)
    page.search('a').map do |link|
      next if link['href'].nil?

      link['href'] if valid_internal_link(link['href'])
    end.compact
  end

  private

  def extract_base_url(absolute_url)
    uri = URI(absolute_url)

    uri.to_s.chomp(uri.path)
  end

  def valid_internal_link(link)
    link.start_with?(base_domain) || link_is_relative(link)
  end

  def link_is_relative(link)
    link.start_with?('/') &&
      %r{\/\b[a-zA-Z]*\b}.match?(link)
  end

  def connection(domain)
    Faraday.new(url: domain) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
  end

  def response(domain)
    connection(domain).get do |request|
      request.options.timeout = TIMEOUT
    end
  end
end
