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
        link_format = asset.include?("::") ? asset.split("::").last : asset.split(".").last
        asset_link = format_string(link_format) % asset.split("::").first
        asset_insertions << asset_link
      end
      asset_insertions
    end

    private

    def format_string(link_format)
      formats ||= formats_merge(DEFAULT_FORMATS, @config["formats"])
      formats[link_format] || "%s"
    end

    def formats_merge(default, custom)
      custom.merge default do |_key, custom_setting, default_setting|
        custom_setting unless default_setting.respond_to? :merge
      end
    end

    def combined_assets
      # Container
      assets = []

      # Add assets
      assets.concat(Array(@config["master"]))
      assets.concat(Array(preset_files))
      assets.concat(Array(@page_config["files"]))

      append_base(assets.uniq)
    end

    def append_base(assets)
      base = @config["source"].to_s
      base += "/" unless base.end_with?("/") || base.empty?

      assets.map { |asset| asset.start_with?("http") ? asset : base + asset }
    end

    def preset_files
      # Collect assets from presets
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
      remaining?(bad_presets) # Raise error for undefined errors
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
