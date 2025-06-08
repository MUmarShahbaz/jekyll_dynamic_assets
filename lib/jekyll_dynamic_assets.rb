# frozen_string_literal: true

require_relative "jekyll_dynamic_assets/version"
require_relative "jekyll_dynamic_assets/processor"
require_relative "jekyll_dynamic_assets/assets_tag"
require_relative "jekyll_dynamic_assets/defaults/formats"
require_relative "jekyll_dynamic_assets/defaults/sources"

module JekyllDynamicAssets
  class Error < StandardError; end
end

Liquid::Template.register_tag("inject_assets", JekyllDynamicAssets::AssetsTag)
