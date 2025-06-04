# frozen_string_literal: true

module JekyllDynamicAssets
  class Processor
    def initialize(site:, page:)
      @config = site.config["assets"] || {}
      @page = page
      @page_config = page["assets"] || {}
    end

    def assets
      all_assets = combined_assets
      asset_insertions = []
      all_assets.each do |asset|
        extension = asset.split(".").last
        asset_link = format_string(extension) % asset
        asset_insertions << asset_link
      end
      asset_insertions
    end

    private

    def format_string(extension)
      formats = @config["formats"] || {}
      formats[extension] || "%s"
    end

    def combined_assets
      require 'set'

      # Container
      assets = []

      # Add master assets and manual assets
      assets.concat(Array(@config["master"]))
      assets.concat(Array(@page_config["files"]))

      # Handle presets selected by front matter
      selected_presets = Set.new(Array(@page_config["presets"]))
      all_presets = @config["presets"] || []

      all_presets.each do |preset|
        preset.each do |name, files|
          if selected_presets.include?(name)
            assets.concat(Array(files))
            selected_presets.delete(name)
          end
        end
      end

      # Display the undefined presets
      selected_presets.each do |missing|
        raise "DynamicAssets: No '#{missing}' preset defined \n\t at: #{@page['path'] || @page['relative_path'] || 'unknown'}"
      end

      assets.uniq
    end
  end
end
