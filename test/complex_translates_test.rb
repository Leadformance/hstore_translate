# -*- encoding : utf-8 -*-
require 'test_helper'
require 'i18n'

class ComplexTranslatesTest < HstoreTranslate::Test
  def setup
    I18n.enforce_available_locales = false
    @p = Post.new(:title_translations => { 
      "nl" => "color", 
      "en" => "color",
      "en-GB" => "colour",
      "zh" => "顏色",
      "zh-CN" => "颜色"})
  end

  def test_retrieve_specific_language_region_zh_cn
    I18n.with_locale("zh-CN") do
      assert_equal("颜色", @p.title)
    end
  end

  def test_retrieves_default_for_language_english_en_us
    I18n.with_locale("en-US") do
      assert_equal("color", @p.title)
    end
  end

  def test_retrieve_default_for_language_chinese_zh_tw
    I18n.with_locale("zh-TW") do
      assert_equal("顏色", @p.title)
    end
  end

  def test_retrieve_unsupported_language_region_fr_fr
    I18n.with_locale("fr-FR") do
      assert_equal("color", @p.title)
    end
  end
end
