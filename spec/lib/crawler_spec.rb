# frozen_string_literal: true

require 'spec_helper'
require './lib/crawler'

RSpec.describe Crawler do
  CRAWLER_SPEC_TIMEOUT = 0.5

  describe '#initialize' do
    let(:domain) { 'https://monzo.com' }
    let(:absolute_path) { domain + '/about' }

    it 'sets the :base_domain attribute' do
      crawler = described_class.new(absolute_path)

      expect(crawler.base_domain).to eq(domain)
    end
  end

  describe '#crawl_internal_links' do
    context 'when requesting good URIs' do
      let(:domain) { 'https://monzo.com' }
      let(:html_body) do
        <<-HTML
        <html>
          <head><title>Monzo - The Bank of the Future</title></head>
          <body>
            <header>
              <div>
                <a href="/" title="Monzo Home Page">Monzo</a>
                <nav>
                  <a href="/about">About</a>
                  <a href="/blog">Blog</a>
                  <a href="/community">Community</a>
                  <a href="/help">Help</a>
                </nav>
              </div>
            </header>
          </body>
          <footer>
            <div>
              <nav>
                <a href="https://twitter.com">Twitter</a>
                <a href="https://facebook.com">Facebook</a>
                <a href="https://instagram.com">Instagram</a>
              </nav>
            </div>
          </footer>
        </html
        HTML
      end

      let(:expected_links) do
        %w[
          /about
          /blog
          /community
          /help
        ]
      end

      let(:unexpected_links) do
        %w[
          /
          https://twitter.com
          https://facebook.com
          https://instagram.com
        ]
      end

      let(:response_mock) do
        double(
          'Response Mock',
          body: html_body,
          status: 200
        )
      end

      let(:crawler) { described_class.new(domain) }

      before do
        allow(crawler)
          .to receive(:response)
          .with(domain)
          .and_return(response_mock)
      end

      it 'returns internal links for a given domain' do
        retrieved_links = crawler.crawl_internal_links(domain)

        aggregate_failures do
          unexpected_links.each do |bad_link|
            expect(retrieved_links).not_to include(bad_link)
          end

          expect(retrieved_links).to match_array(expected_links)
        end
      end
    end

    context 'when requesting bad URIs' do
      let(:crawler) { described_class.new(bad_domain) }

      before do
        allow(crawler)
          .to receive(:response)
          .with(bad_domain)
          .and_return(response_mock)
      end

      context 'receiving a 404' do
        let(:bad_domain) { 'https://monzo.com/not-a-page' }
        let(:response_mock) { double('Response Mock', status: 404) }

        it 'does not scrape the page and returns nil' do
          does_not_scrape_page(bad_domain)
        end
      end

      context 'when the response redirects to a different site' do
        let(:bad_domain) { 'https://sneaky-redirect.com/not-a-page' }
        let(:response_mock) { double('Response Mock', status: 302) }

        it 'does not scrape the page and returns nil' do
          does_not_scrape_page(bad_domain)
        end
      end

      context 'when the response returns a 500' do
        let(:bad_domain) { 'https://500.com/not-a-page' }
        let(:response_mock) { double('Response Mock', status: 500) }

        it 'does not scrape the page and returns nil' do
          does_not_scrape_page(bad_domain)
        end
      end
    end
  end

  private

  def does_not_scrape_page(bad_domain)
    expect(Nokogiri::HTML::Document).not_to receive(:parse).with(any_args)

    retrieved_links = crawler.crawl_internal_links(bad_domain)

    expect(retrieved_links).to be_nil
  end
end
