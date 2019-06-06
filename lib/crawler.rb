# frozen_string_literal: true

require 'nokogiri'
require 'faraday'

class Crawler
  class << self
    TIMEOUT = 0.5
    BAD_HTTP_STATUSES = [500, 404, 302, 301].freeze

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

    def valid_internal_link(link)
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
end
