# frozen_string_literal: true

require 'spec_helper'
require './lib/crawler'
require './lib/site_mapper'

RSpec.describe SiteMapper do
  subject { described_class.new(domain) }
  let(:domain) { 'https://monzo.com' }

  describe '#map_site' do
    context 'when the domain is present' do
      it 'calls #retrieve_internal_links' do
        expect(subject).to receive(:retrieve_internal_links)
          .with(array_including(domain))

        subject.map_site
      end
    end

    context 'when the domain is nil' do
      let(:domain) { nil }

      it 'prompts the user to provide a domain' do
        expect { subject.map_site }
          .to output("Please provide a domain to crawl\n")
          .to_stdout
      end
    end
  end

  describe '#retrieve_internal_links' do

    let(:first_links) do
      %w[
        /about
        /blog
        /community
        /help
      ]
    end

    context 'no nested links' do
      let(:expected_site_map) do
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
        expect(subject.map_site).to eq(expected_site_map)
      end
    end

    context 'with nested links' do
      let(:about_nested_links) do
        %w[
          /community/making-monzo
          /faq
          /legal/cookie-policy
          /blog
        ]
      end

      let(:initial_site_map) do
        {
          "#{domain}": {
            "/about": {},
            "/blog": {},
            "/community": {},
            "/help": {}
          }
        }
      end

      let(:expected_site_map) do
        {
          "#{domain}": {
            "/about": {},
            "/blog": {},
            "/community": { "/making-monzo": {} },
            "/help": {},
            "/faq": {},
            "/legal": { "/cookie-policy": {} }
          }
        }
      end

      before do
        subject.site_map = initial_site_map
        subject.encountered_paths = Set[first_links]

        allow(Crawler).to receive(:crawl_internal_links)
          .and_return(about_nested_links)
      end

      it 'nests links under the correct path' do
        expect(subject.map_site).to include(expected_site_map)
      end
    end
  end
end
