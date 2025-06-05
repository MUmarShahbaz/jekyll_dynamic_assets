# JekyllDynamicAssets

JekyllDynamicAssets is a Jekyll plugin that allows you to dynamically manage and inject CSS, JS and other assets into your site using presets, per-page configuration, and flexible formatting.

## Features
- Define global (master) assets and per-page assets
- Use asset presets for reusable asset groups
- Customizable HTML output for each asset type (CSS, JS, etc.)
- Liquid tag `{% assets %}` for easy asset injection in templates and includes

## Installation

Add this line to your application's Gemfile:

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

## Usage

1. **Configure your assets in `config.yml`:**

```yaml
assets:
  master:
    - main.css
    - main.js
  formats:
    css: "<link rel='stylesheet' href='%s'>"
    js:  "<script src='%s'></script>"
  presets:
    blog: [blog.css, blog.js]
    project: [project.css, project.js]
```

2. **Per-page or per-collection configuration:**

In your page or post front matter:

```yaml
assets:
  files:
    - custom.css
  presets:
    - blog
```

3. **Inject assets in your templates:**

Use the Liquid tag where you want the assets to appear:

```liquid
{% assets %}
```

This will output the appropriate HTML tags for all configured assets. This tag should generally be used inside your `<head>` tag but can be used anywhere else.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MUmarShahbaz/jekyll_dynamic_assets. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/MUmarShahbaz/jekyll_dynamic_assets/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the JekyllDynamicAssets project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/MUmarShahbaz/jekyll_dynamic_assets/blob/main/CODE_OF_CONDUCT.md).
