# frozen_string_literal: true

require 'spec_helper'
require './lib/crawler'
require './lib/site_mapper'

RSpec.describe SiteMapper do
  describe '#retrieve_internal_links' do
    let(:domain) { 'https://monzo.com' }

    subject { described_class.new(domain) }

    let(:first_links) do
      %w[
        /about
        /blog
        /community
        /help
      ]
    end

    context 'no nested links' do
      let(:expected_links) do
        {
          "#{domain}": {
            "/about": {},
            "/blog": {},
            "/community": {},
            "/help": {}
          }
        }
      end

      before do
        allow(Crawler).to receive(:crawl_internal_links)
          .and_return(first_links)
      end

      it 'returns internal links for a given domain' do
        expect(subject.map_site).to eq(expected_links)
      end
    end
  end
end
