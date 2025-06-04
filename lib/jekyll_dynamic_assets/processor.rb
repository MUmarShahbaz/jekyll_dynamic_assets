# frozen_string_literal: true

module JekyllDynamicAssets
  # Asset link generator
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
      # Container
      assets = []

      # Add master assets and manual assets
      assets.concat(Array(@config["master"]))
      assets.concat(Array(preset_files))
      assets.concat(Array(@page_config["files"]))

      assets.uniq
    end

    def preset_files
      preset_assets = []
      bad_presets = []
      selected_presets = Array(@page_config["presets"])
      preset_map = @config["presets"] || {}
      selected_presets.each do |preset|
        if preset_map.key?(preset)
          preset_assets.concat(Array(preset_map[preset]))
        else
          bad_presets << preset
        end
      end
      remaining?(bad_presets)
      preset_assets
    end

    def remaining?(remaining_presets)
      # Display the undefined presets
      return if remaining_presets.empty?

      location = @page["path"] || @page["relative_path"] || "unknown"
      missing_list = remaining_presets.to_a.join(", ")
      raise "DynamicAssets: No preset(s) defined: #{missing_list} at: #{location}"
    end
  end
end
