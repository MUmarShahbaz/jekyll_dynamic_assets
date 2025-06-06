# JekyllDynamicAssets

JekyllDynamicAssets is a Jekyll plugin that allows you to dynamically manage and inject CSS, JS, and other head assets into your site using presets, per-page configuration, and flexible formatting.

## Features
- Define global (master) assets and per-page assets
- Use asset presets for reusable asset groups
- Pre-defined default formats for common assets, can be overwritten
- Liquid tag `{% assets %}` for easy asset injection in templates and includes
- Error reporting for missing presets

## Installation

Add this to your Jekyll site's `Gemfile`:

```ruby
source 'https://rubygems.org'

gem "jekyll"

group :jekyll_plugins do
  gem "jekyll_dynamic_assets"
  # other gems
end
```

Then add the following to your Jekyll site's `config.yml`:

```yaml
plugins:
  - jekyll_dynamic_assets
```

Finally, in your terminal run:

```bash
bundle install
```

## Usage

1. **Configure your assets in `config.yml`:**

```yaml
assets:
  master: # Master assets
    - main.css
    - main.js
  source: "/assets/" # Optional: base path for all assets
  formats:
    js:  "<script defer src='%s'></script>" # Overwrite defaults
    xyz: "<custom> %s </custom>"  # Define Custom formats
  presets:  # Create presets to include multiple assets
    blog: [blog.css, blog.js]
    project: [project.css, project.js, code-highlight.css, slideshow.js, myApp.js]
```

2. **Per-page or per-collection configuration:**

In your page or post front matter:

```yaml
assets:
  files:
    - manual.css # include singular files
  presets:
    - blog  # Use a preset
```

3. **Inject assets in your templates:**

Use the Liquid tag where you want the assets to appear (typically in your `<head>`):

```liquid
<head>
  <!-- other tags like meta etc. -->

  {% assets %}
</head>
```

This will output the appropriate HTML tags for all configured assets. The tag should generally be used inside your `<head>` tag but can be used anywhere else.

For assets which you haven't defined any format and there isn't any default for it either, the code will simply write the name of that asset.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MUmarShahbaz/jekyll_dynamic_assets. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/MUmarShahbaz/jekyll_dynamic_assets/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the JekyllDynamicAssets project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/MUmarShahbaz/jekyll_dynamic_assets/blob/main/CODE_OF_CONDUCT.md).
