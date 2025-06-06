# frozen_string_literal: true

require_relative "test_helper"
require "jekyll"
require "fileutils"

class JekyllDynamicAssetsTest < Minitest::Test
  def setup
    @source = File.expand_path("main", __dir__)
    @dest = File.expand_path("_main_site", __dir__)
    FileUtils.rm_rf(@dest) # clean previous builds

    @config = Jekyll.configuration(
      "source" => @source,
      "destination" => @dest,
      "quiet" => true
    )
    @site = Jekyll::Site.new(@config)
  end

  def build_and_load(name)
    @site.process
    page = @site.pages.find { |p| p.name == name }
    refute_nil page, "#{name} not found"
    refute_includes page.content, "{% assets %}", "Tag not replaced at #{name}"
    page
  end

  def test_master_only
    page = build_and_load("master_only.html")

    assert_includes page.content, '<link rel="stylesheet" href="main.css">'
    assert_includes page.content, '<script src="main.js"></script>'
  end

  def test_blog
    page = build_and_load("blog.html")

    assert_includes page.content, '<link rel="stylesheet" href="main.css">'
    assert_includes page.content, '<script src="main.js"></script>'
    assert_includes page.content, '<link rel="stylesheet" href="blog.css">'
  end

  def test_project
    page = build_and_load("project.html")

    assert_includes page.content, '<link rel="stylesheet" href="main.css">'
    assert_includes page.content, '<script src="main.js"></script>'
    assert_includes page.content, '<link rel="stylesheet" href="project.css">'
    assert_includes page.content, '<script src="project.js"></script>'
  end

  def test_project_blog
    page = build_and_load("project_blog.html")

    assert_includes page.content, '<link rel="stylesheet" href="main.css">'
    assert_includes page.content, '<script src="main.js"></script>'
    assert_includes page.content, '<link rel="stylesheet" href="project.css">'
    assert_includes page.content, '<script src="project.js"></script>'
    assert_includes page.content, '<link rel="stylesheet" href="blog.css">'
  end

  def test_other
    page = build_and_load("other.html")

    assert_includes page.content, '<link rel="stylesheet" href="main.css">'
    assert_includes page.content, '<script src="main.js"></script>'
    assert_includes page.content, '<link rel="stylesheet" href="other.css">'
    assert_includes page.content, '<script src="other.js"></script>'
    assert_includes page.content, "<asset> other.xyz </asset>"
  end

  def test_missing_formats
    page = build_and_load("missing_format.html")

    assert_includes page.content, '<link rel="stylesheet" href="main.css">'
    assert_includes page.content, '<script src="main.js"></script>'
    assert_match(/\bother\.miss\b/, page.content)
  end

  def test_overwrite_formats
    page = build_and_load("overwrite.html")

    assert_includes page.content, '<link rel="stylesheet" href="main.css">'
    assert_includes page.content, '<script src="main.js"></script>'
    refute_includes page.content, '<link rel="preload" href="other.ttf" as="font" type="font/ttf" crossorigin>', "Format not overwritten"
    assert_includes page.content, '<custom> overwrite.ttf </custom>'
  end

  def test_bad_preset
    bad_config = Jekyll.configuration(
      "source" => File.expand_path("bad", __dir__),
      "destination" => File.expand_path("_bad_site", __dir__),
      "quiet" => true
    )
    bad_site = Jekyll::Site.new(bad_config)
    error = assert_raises(RuntimeError) do
      bad_site.process
    end

    assert_match(/^DynamicAssets: No preset\(s\) defined: .+ at: .+$/, error.message)
  end
end
