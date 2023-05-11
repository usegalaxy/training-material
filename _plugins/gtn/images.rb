# frozen_string_literal: true
require 'jekyll'
# The fastimage gem may not be installed, and that is OK, we will fall back to another method
FASTIMAGE_AVAILABLE = true
begin
  require 'fastimage'
rescue LoadError
  Jekyll.logger.info '[GTN/Images] Could not load fastimage gem, disabling feature (probably due to conda)'
  FASTIMAGE_AVAILABLE = false
end

module Gtn
  module Images
    def self.cache
      @@cache ||= Jekyll::Cache.new('ImageDimensions')
    end

    def self.html_image_dimensions(tuto_dir, url)
      return '' if !FASTIMAGE_AVAILABLE

      width, height = get_image_dimensions(tuto_dir, url)
      return unless width && height

      %(width="#{width}" height=#{height})
    end

    def self.get_image_dimensions(tuto_dir, url)
      if match = url.match(%r{^{{\s*site.baseurl\s*}}/(.*)})
        _get_image_dimensions(match[1].strip)
      elsif match = url.match(/{%\s*link\s*(.*)\s*%}/)
        _get_image_dimensions(match[1].strip)
      elsif !url.match(%r{https?://})
        img_path = File.absolute_path(File.join(tuto_dir, url))
        _get_image_dimensions(img_path) if File.exist?(img_path)
      else
        _get_image_dimensions(img_path)
      end
    end

    def self._get_image_dimensions(path)
      cache.getset(path) do
        FastImage.size(path)
      rescue StandardError
        puts "Could not resolve size of #{path}"
      end
    end
  end
end

if $0 == __FILE__
end
