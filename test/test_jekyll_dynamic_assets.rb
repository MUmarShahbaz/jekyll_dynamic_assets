# frozen_string_literal: true

require_relative "test_helper"
require "jekyll"
require "fileutils"

class JekyllDynamicAssetsTest < Minitest::Test
  def setup
    # Clean previous build
    FileUtils.rm_rf("_out1")
    FileUtils.rm_rf("_out2")
    FileUtils.rm_rf("_out3")

    # Create Jekyll sites
    @main_site = new_site("main_site", "_out1")
    @bad_preset_site = new_site("bad_preset_site", "_out2")
    @source_var_site = new_site("source_var_site", "_out3")
  end

  def new_site(source, out)
    config = Jekyll.configuration(
      "source" => File.expand_path(source, __dir__),
      "destination" => File.expand_path(out, __dir__),
      "quiet" => true
    )
    Jekyll::Site.new(config)
  end

  def build_and_load(name, site)
    site.process
    page = site.pages.find { |p| p.name == name }
    refute_nil page, "#{name} not found in #{site}"
    refute_includes page.content, "{% assets %}", "Tag not replaced at #{name} of #{site}"
    page
  end

  def test_master_only
    page = build_and_load("master_only.html", @main_site)

    assert_includes page.content, '<link rel="stylesheet" href="main.css">'
    assert_includes page.content, '<script src="main.js"></script>'
  end

  def test_blog
    page = build_and_load("blog.html", @main_site)

    assert_includes page.content, '<link rel="stylesheet" href="main.css">'
    assert_includes page.content, '<script src="main.js"></script>'
    assert_includes page.content, '<link rel="stylesheet" href="blog.css">'
  end

  def test_project
    page = build_and_load("project.html", @main_site)

    assert_includes page.content, '<link rel="stylesheet" href="main.css">'
    assert_includes page.content, '<script src="main.js"></script>'
    assert_includes page.content, '<link rel="stylesheet" href="project.css">'
    assert_includes page.content, '<script src="project.js"></script>'
  end

  def test_project_blog
    page = build_and_load("project_blog.html", @main_site)

    assert_includes page.content, '<link rel="stylesheet" href="main.css">'
    assert_includes page.content, '<script src="main.js"></script>'
    assert_includes page.content, '<link rel="stylesheet" href="project.css">'
    assert_includes page.content, '<script src="project.js"></script>'
    assert_includes page.content, '<link rel="stylesheet" href="blog.css">'
  end

  def test_other
    page = build_and_load("other.html", @main_site)

    assert_includes page.content, '<link rel="stylesheet" href="main.css">'
    assert_includes page.content, '<script src="main.js"></script>'
    assert_includes page.content, '<link rel="stylesheet" href="other.css">'
    assert_includes page.content, '<script src="other.js"></script>'
    assert_includes page.content, "<asset> other.xyz </asset>"
  end

  def test_missing_formats
    page = build_and_load("missing_format.html", @main_site)

    assert_includes page.content, '<link rel="stylesheet" href="main.css">'
    assert_includes page.content, '<script src="main.js"></script>'
    assert_match(/\bother\.miss\b/, page.content)
  end

  def test_overwrite_formats
    page = build_and_load("overwrite.html", @main_site)

    assert_includes page.content, '<link rel="stylesheet" href="main.css">'
    assert_includes page.content, '<script src="main.js"></script>'
    refute_includes page.content, '<link rel="preload" href="other.ttf" as="font" type="font/ttf" crossorigin>', "Format not overwritten"
    assert_includes page.content, "<custom> overwrite.ttf </custom>"
  end

  def test_bad_preset
    error = assert_raises(RuntimeError) do
      @bad_preset_site.process
    end

    assert_match(/^DynamicAssets: No preset\(s\) defined: .+ at: .+$/, error.message)
  end

  def test_source_var
    page = build_and_load("source_var.html", @source_var_site)

    assert_includes page.content, '<link rel="stylesheet" href="assets/main.css">'
    assert_includes page.content, '<script src="assets/main.js"></script>'
  end
end
