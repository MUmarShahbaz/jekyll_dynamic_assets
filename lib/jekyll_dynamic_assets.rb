# frozen_string_literal: true

require_relative "jekyll_dynamic_assets/version"
require_relative "jekyll_dynamic_assets/processor"
require_relative "jekyll_dynamic_assets/assets_tag"

module JekyllDynamicAssets
  class Error < StandardError; end
end

Liquid::Template.register_tag('assets', JekyllDynamicAssets::AssetsTag)