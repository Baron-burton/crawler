# frozen_string_literal: true

require 'spec_helper'
require './lib/crawler'

RSpec.describe Crawler do
  describe '.crawl_internal_links' do
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

      before do
        expect(described_class).to receive(:open).and_return(html_body)
      end

      it 'returns internal links for a given domain' do
        retrieved_links = described_class.crawl_internal_links(domain)

        aggregate_failures do
          unexpected_links.each do |bad_link|
            expect(retrieved_links).not_to include(bad_link)
          end

          expect(retrieved_links).to match_array(expected_links)
        end
      end
    end

    context 'when requesting bad URIs' do
      let(:bad_domain) { 'https://monzo.com/not-a-page' }

      it 'returns an error message' do
        expect { described_class.crawl_internal_links(bad_domain) }
          .to output("Couldn't retrieve links from #{bad_domain}\n")
          .to_stdout
      end
    end
  end
end
