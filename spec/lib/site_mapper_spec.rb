# frozen_string_literal: true

require 'spec_helper'
require './lib/crawler'
require './lib/site_mapper'

RSpec.describe SiteMapper do
  describe '#retrieve_internal_links' do
    let(:domain) { 'https://monzo.com' }

    let(:crawled_links) do
      %w[
        /about
        /blog
        /community
        /help
      ]
    end

    let(:expected_links) do
      [domain] + crawled_links
    end

    subject { described_class.new(domain) }

    before do
      allow(Crawler).to receive(:crawl_internal_links).and_return(crawled_links)
    end

    it 'returns internal links for a given domain' do
      expect(subject.retrieve_internal_links).to eq(expected_links)
    end
  end
end
