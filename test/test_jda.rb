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
    FileUtils.rm_rf("_out4")
    FileUtils.rm_rf("_out5")
    FileUtils.rm_rf("_out6")
    FileUtils.rm_rf("_out7")

    # Create Jekyll sites
    @ait_site = new_site("ait_site", "_out1") # Asset Injection Test
    @pft_site = new_site("pft_site", "_out2") # Preset Fail Test
    @fft_site = new_site("fft_site", "_out3") # Format Fail Test
    @sft_site = new_site("sft_site", "_out4") # Source Formatting Test
    @aut_site = new_site("aut_site", "_out5") # Absolute URL Test
    @sst_site = new_site("sst_site", "_out6") # String Source Test
    @ebt_site = new_site("ebt_site", "_out7") # External Base Test
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
    refute_includes page.content, "{% inject_assets %}", "Tag not replaced at #{name} of #{site}"
    page
  end

  # Asset Injection Tests
  def test_master_only
    page = build_and_load("master_only.html", @ait_site)

    assert_includes page.content, '<link rel="stylesheet" href="/assets/styles/main.css">'
    assert_includes page.content, '<script src="/assets/scripts/main.js"></script>'
  end

  def test_project_only
    page = build_and_load("project_only.html", @ait_site)

    assert_includes page.content, '<link rel="stylesheet" href="/assets/styles/main.css">'
    assert_includes page.content, '<script src="/assets/scripts/main.js"></script>'
    assert_includes page.content, '<link rel="stylesheet" href="/assets/styles/project.css">'
    assert_includes page.content, '<script src="/assets/scripts/project.js"></script>'
  end

  def test_blog_only
    page = build_and_load("blog_only.html", @ait_site)

    assert_includes page.content, '<link rel="stylesheet" href="/assets/styles/main.css">'
    assert_includes page.content, '<script src="/assets/scripts/main.js"></script>'
    assert_includes page.content, '<link rel="stylesheet" href="/assets/styles/blog.css">'
  end

  def test_project_blog
    page = build_and_load("project_blog.html", @ait_site)

    assert_includes page.content, '<link rel="stylesheet" href="/assets/styles/main.css">'
    assert_includes page.content, '<script src="/assets/scripts/main.js"></script>'
    assert_includes page.content, '<link rel="stylesheet" href="/assets/styles/project.css">'
    assert_includes page.content, '<script src="/assets/scripts/project.js"></script>'
    assert_includes page.content, '<link rel="stylesheet" href="/assets/styles/blog.css">'
  end

  def test_single_files
    page = build_and_load("single_files.html", @ait_site)

    assert_includes page.content, '<link rel="stylesheet" href="/assets/styles/main.css">'
    assert_includes page.content, '<script src="/assets/scripts/main.js"></script>'
    assert_includes page.content, "<asset> /assets/file.xyz </asset>"
  end

  def test_project_blog_single
    page = build_and_load("project_blog_single.html", @ait_site)

    assert_includes page.content, '<link rel="stylesheet" href="/assets/styles/main.css">'
    assert_includes page.content, '<script src="/assets/scripts/main.js"></script>'
    assert_includes page.content, '<link rel="stylesheet" href="/assets/styles/project.css">'
    assert_includes page.content, '<script src="/assets/scripts/project.js"></script>'
    assert_includes page.content, '<link rel="stylesheet" href="/assets/styles/blog.css">'
    assert_includes page.content, "<asset> /assets/file.xyz </asset>"
  end

  def test_formatting
    page = build_and_load("formatting.html", @ait_site)

    assert_includes page.content, '<link rel="stylesheet" href="/assets/styles/main.css">'
    assert_includes page.content, '<script src="/assets/scripts/main.js"></script>'
    assert_includes page.content, "<custom> /assets/fonts/overwrite.ttf </custom>" # Overwrite test
    assert_includes page.content, '<script defer src="/assets/scripts/select.js"></script>' # Selection test
    assert_includes page.content, "<manual> /assets/scripts/manual-define.js </manual>" # Inline-format test
  end

  # Preset Fail Test
  def test_bad_preset
    error = assert_raises(KeyError) do
      @pft_site.process
    end

    assert_match(/^DynamicAssets: No preset\(s\) defined: .+/, error.message)
  end

  # Format Fail Test
  def test_bad_format
    error = assert_raises(KeyError) do
      @fft_site.process
    end

    assert_match(/^DynamicAssets: No .+ format defined/, error.message)
  end

  # Source Formatting Test
  def test_source
    page = build_and_load("source.html", @sft_site)

    assert_includes page.content, '<link rel="stylesheet" href="/mySource/css/main.css">' # Overwrite test
    assert_includes page.content, '<script src="/mySource/js/main.js"></script>'
    assert_includes page.content, '<link rel="stylesheet" href="/mySource/select/selecting.css">' # Select test
    assert_includes page.content, '<script src="/mySource/manual/manual-select.js"></script>' # Manual test
    assert_includes page.content, '<script src="https://myweb.com/file.js"></script>' # External & Manual test
    assert_includes page.content, '<link rel="stylesheet" href="https://github.com/github.css">' # External & Select test
  end

  def test_source_with_formatting
    page = build_and_load("source.html", @sft_site)

    assert_includes page.content, '<link rel="stylesheet" href="/mySource/select/selecting.css" crossorigin>' # Select Source and Select Format test
    assert_includes page.content, '<script defer src="/mySource/manual/manual-select.js"></script>' # Manual Source and Select Format test

    assert_includes page.content, '<link rel="preload" href="/mySource/select/selecting.css" as="style" onload="this.onload=null;this.rel=\'stylesheet\'">' # Select Source and Manual Format test
    assert_includes page.content, '<noscript><link rel="stylesheet" href="/mySource/manual/manual-select.css"></noscript>' # Manual Source and Manual Format test

    assert_includes page.content, '<script defer src="https://myweb.com/file.js"></script>' # External, Manual Source and Select Format
    assert_includes page.content, '<noscript><link rel="stylesheet" href="https://github.com/github.css"></noscript>' # External, Select Source and Manual Format
  end

  # Absolute URL Test
  def test_absolute
    page = build_and_load("absolute.html", @aut_site)

    assert_includes page.content, '<link rel="stylesheet" href="https://mywebsite/sub/mySource/css/main.css">' # Overwrite test
    assert_includes page.content, '<script src="https://mywebsite/sub/mySource/js/main.js"></script>'
    assert_includes page.content, '<link rel="stylesheet" href="https://mywebsite/sub/mySource/select/selecting.css">' # Select test
    assert_includes page.content, '<script src="https://mywebsite/sub/mySource/manual/manual-select.js"></script>' # Manual test
    assert_includes page.content, '<script src="https://myweb.com/file.js"></script>' # External & Manual test
    assert_includes page.content, '<link rel="stylesheet" href="https://github.com/github.css">' # External & Select test
  end

  # String Source Test
  def test_string_source
    page = build_and_load("string_source.html", @sst_site)

    assert_includes page.content, '<link rel="stylesheet" href="/mySource/main.css">'
    assert_includes page.content, '<script src="/mySource/main.js"></script>'
  end

  # External Base Test
  def test_external_base
    page = build_and_load("external_base.html", @ebt_site)

    assert_includes page.content, '<link rel="stylesheet" href="https://myCDN.com/mySource/css/main.css">'
    assert_includes page.content, '<script src="https://myCDN.com/mySource/js/main.js"></script>'
  end
end
