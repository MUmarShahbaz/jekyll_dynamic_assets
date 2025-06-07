# frozen_string_literal: true

module JekyllDynamicAssets
  # Asset link generator
  class Processor
    def initialize(site:, page:)
      @config = site.config["assets"] || {}
      @page = page
      @page_config = page["assets"] || {}
      @path = @page["path"] || @page["relative_path"] || "unknown"

      sub_configs(site:)
    end

    # Get all link tags to assets for this page
    def assets
      all_assets = combined_assets
      asset_insertions = []
      all_assets.each do |dir, asset, format_string|
        directory = dir.start_with?("http") ? dir : prepare_dir(dir)
        asset_link = directory + asset
        asset_insertions << format_string % asset_link
      end
      asset_insertions
    end

    private

    def sub_configs(site:)
      @link_formats ||= setting_merge(DEFAULT_FORMATS, @config["formats"]) # Format Config

      # Standardize Source Config
      srcs ||= setting_merge(DEFAULT_SOURCES, @config["source"])
      @asset_sources = if srcs.is_a?(String)
                         {
                           "base" => srcs
                         }.freeze
                       else
                         srcs
                       end

      # Get URL for absolute_url filter
      return unless @config["absolute"] == true

      @url = (site.config["url"] || "") + (site.config["baseurl"] || "")
    end

    def setting_merge(default, custom)
      if custom.nil?
        default
      elsif custom.is_a?(String)
        custom
      else
        custom.merge default do |_key, custom_setting, default_setting|
          custom_setting unless default_setting.respond_to? :merge
        end
      end
    end

    def prepare_dir(dir)
      # Format URL assuming standard inputs, all leading slashes and no trailing
      directory = @config["absolute"] ? @url : ""
      directory += @asset_sources["base"] unless @asset_sources["base"] == ""
      directory += dir unless dir.empty? || dir == ""
      directory += "/"
      directory
    end

    def get_sub_dir(string)
      return string.split("<<<").first if string.include?("<<<")

      hash = string.include?("<<") ? string.split("<<").first : string.split(".").last

      @asset_sources.fetch(hash) do
        warn "DynamicAssets: No source defined for #{hash.inspect} in #{@path} - using base source"
        ""
      end
    end

    def get_format(string)
      return string.split(":::").last if string.include?(":::")

      hash = string.include?("::") ? string.split("::").last : string.split(".").last

      @link_formats.fetch(hash) do
        raise KeyError, "DynamicAssets: No #{hash.inspect} format defined"
      end
    end

    def combined_assets
      # Container
      raw_assets = []
      assets = []

      # Add assets
      raw_assets.concat(Array(@config["master"]))
      raw_assets.concat(Array(preset_files))
      raw_assets.concat(Array(@page_config["files"]))

      raw_assets.uniq.each do |asset|
        assets << asset_array(asset)
      end
      assets
    end

    def asset_array(asset)
      buff = Array.new(3)
      buff[2] = get_format(asset)         # Store Format
      asset = asset.split(/:{2,}/).first  # Remove Format selector
      buff[0] = get_sub_dir(asset)        # Store Source
      asset = asset.split(/<{2,}/).last   # Remove Source selector
      buff[1] = asset                     # Store Asset path

      buff
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

      remaining_presets?(bad_presets) # Raise error for undefined errors
      preset_assets
    end

    def remaining_presets?(remaining_presets)
      # return if no undefined presets
      return if remaining_presets.empty?

      # Raise error for all undefined presets
      missing_list = remaining_presets.to_a.join(", ")
      raise KeyError, "DynamicAssets: No preset(s) defined: #{missing_list}"
    end
  end
end
