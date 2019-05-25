# frozen_string_literal: true

require 'set'

class SiteMapper
  attr_reader :domain
  attr_accessor :site_map, :encountered_paths

  def initialize(domain)
    @domain = domain
    @site_map = { "#{domain}": {} }
    @encountered_paths = Set.new
  end

  def map_site
    retrieve_internal_links([domain])
  end

  def retrieve_internal_links(paths)
    retrieved_paths = nil

    paths.each do |path|
      full_path = build_path(path)

      retrieved_paths = Crawler.crawl_internal_links(full_path)
      add_to_site_map(retrieved_paths)
    end

    unless retrieved_paths_mapped_already(retrieved_paths)
      retrieve_internal_links(retrieved_paths)
    end

    site_map
  end

  private

  def build_path(path)
    return domain if path == domain

    domain + path
  end

  def add_to_site_map(paths)
    paths.each do |path|
      next if encountered_paths.include?(path)

      site_map[domain.to_sym][path.to_sym] = {}
    end

    encountered_paths.merge(paths)
  end

  def retrieved_paths_mapped_already(paths)
    paths.any? do |path|
      !site_map.keys.include?(path)
    end
  end
end
