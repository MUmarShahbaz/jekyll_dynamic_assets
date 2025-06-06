# frozen_string_literal: true

module JekyllDynamicAssets
  DEFAULT_FORMATS = {
    "css" => '<link rel="stylesheet" href="%s">',
    "js" => '<script src="%s"></script>',
    "mjs" => '<script type="module" src="%s"></script>',
    "ts" => '<script type="module" src="%s"></script>',
    "json" => '<link rel="alternate" type="application/json" href="%s">',
    "ico" => '<link rel="icon" href="%s">',
    "woff" => '<link rel="preload" href="%s" as="font" type="font/woff" crossorigin>',
    "woff2" => '<link rel="preload" href="%s" as="font" type="font/woff2" crossorigin>',
    "ttf" => '<link rel="preload" href="%s" as="font" type="font/ttf" crossorigin>',
    "otf" => '<link rel="preload" href="%s" as="font" type="font/otf" crossorigin>'
  }.freeze
end
