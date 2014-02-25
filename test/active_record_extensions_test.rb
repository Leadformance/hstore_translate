# -*- encoding : utf-8 -*-
require 'test_helper'

class ActiveRecordExtensionsTest < HstoreTranslate::Test

  def setup
    I18n.available_locales = [:en, :fr]
  end

  def teardown
    Post.reset_callbacks(:validate)
  end

  def test_validates_presence
    Post.validates_hstore_translate(:title, { presence: true })
    I18n.with_locale(:fr) do
      p = Post.new(title_translations: { "en" => "English Title", "fr" => "" })
      assert p.invalid?
      p.title_fr = 'Titre Français'
      assert p.valid?
    end
  end

  def test_validates_length_minimum
    Post.validates_hstore_translate(:title, { length: { minimum: 6 } })
    I18n.with_locale(:fr) do
      p = Post.new(title_translations: { "en" => "Long Title", "fr" => "Court" })
      assert p.invalid?
      p.title_fr = 'Long Titre'
      assert p.valid?
    end
  end

  def test_validates_length_allow_blank
    Post.validates_hstore_translate(:title, { length: { minimum: 6, allow_blank: true } })
    I18n.with_locale(:fr) do
      p = Post.new(title_translations: { "en" => "Long Title", "fr" => "" })
      assert p.valid?
    end
  end

  def test_validates_length_maximum
    Post.validates_hstore_translate(:title, { length: { maximum: 6 } })
    I18n.with_locale(:fr) do
      p = Post.new(title_translations: { "en" => "Title", "fr" => "Long Titre" })
      assert p.invalid?
      p.title_fr = 'Titre'
      assert p.valid?
    end
  end

  def test_validates_format
    Post.validates_hstore_translate(:title, { format: { with: /\A\w+\z/ } })
    I18n.with_locale(:fr) do
      p = Post.new(title_translations: { "en" => "Title", "fr" => "Titre?" })
      assert p.invalid?
      p.title_fr = 'Titre'
      assert p.valid?
    end
  end

end
