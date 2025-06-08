# frozen_string_literal: true

require "liquid"

module JekyllDynamicAssets
  # {% inject_assets %} tag
  class AssetsTag < Liquid::Tag
    def render(context)
      site = context.registers[:site]
      page = context.registers[:page]

      # Initialize and run the processor
      processor = Processor.new(site: site, page: page)
      processor.assets.join("\n")
    end
  end
end
