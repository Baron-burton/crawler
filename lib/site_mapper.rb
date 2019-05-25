# frozen_string_literal: true

require 'set'
require './lib/crawler'

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
      next if encountered_paths.include?(path)

      puts "Currently on: #{path}"

      encountered_paths.add(path)
      full_path = build_path(path)

      retrieved_paths = ::Crawler.crawl_internal_links(full_path)
      next if retrieved_paths.nil?

      add_to_site_map(retrieved_paths)

      unmapped_paths = retrieved_paths_not_mapped(retrieved_paths)
      retrieve_internal_links(unmapped_paths)
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

      map_position = site_map[domain.to_sym]
      path_elements = path.split('/').reject(&:empty?)

      path_elements.each do |element|
        key = "/#{element}".to_sym

        map_position[key] = {} if map_position[key].nil?
        map_position = map_position[key]
      end
    end
  end

  def retrieved_paths_not_mapped(paths)
    paths.reject do |path|
      encountered_paths.include?(path)
    end
  end
end

puts SiteMapper.new(ARGV.first).map_site
