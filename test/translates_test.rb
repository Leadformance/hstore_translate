# -*- encoding : utf-8 -*-

require 'rubygems'
require 'active_record'
require 'test/unit'

require 'hstore_translate'

class Post < ActiveRecord::Base
  translates :title
end

class TranslatesTest < Test::Unit::TestCase
  def setup
    db_config = YAML.load(File.open(File.join(File.dirname(__FILE__), 'database.yml')).read)['test']

    Post.establish_connection(db_config)

    unless Post.connection.select_value("SELECT proname FROM pg_proc WHERE proname = 'akeys'")
      pgversion = Post.connection.send(:postgresql_version)

      if pgversion < 90100
        pg_sharedir = `pg_config --sharedir`.strip
        hstore_script_path = File.join(pg_sharedir, "contrib", "hstore.sql")
        Post.connection.execute(File.read(hstore_script_path))
      else
        Post.connection.execute("CREATE EXTENSION IF NOT EXISTS hstore")
      end
    end

    Post.connection.create_table(:posts, :force => true) do |t|
      t.column :title_translations, 'hstore'
    end
  end

  def test_assigns_in_current_locale
    I18n.with_locale(:en) do
      p = Post.new(:title => "English Title")
      assert_equal("English Title", p.title_translations['en'])
    end
  end

  def test_retrieves_in_current_locale
    p = Post.new(:title_translations => { "en" => "English Title", "fr" => "Titre français" })
    I18n.with_locale(:fr) do
      assert_equal("Titre français", p.title)
    end
  end

  def test_retrieves_in_current_locale_with_fallbacks
    I18n::Backend::Simple.include(I18n::Backend::Fallbacks)
    I18n.default_locale = :"en-US"

    p = Post.new(:title_translations => {"en" => "English Title"})
    I18n.with_locale(:fr) do
      assert_equal("English Title", p.title)
    end
  end

  def test_assigns_in_specified_locale
    I18n.with_locale(:en) do
      p = Post.new(:title_translations => { "en" => "English Title" })
      p.title_fr = "Titre français"
      assert_equal("Titre français", p.title_translations["fr"])
    end
  end

  def test_retrieves_in_specified_locale
    I18n.with_locale(:en) do
      p = Post.new(:title_translations => { "en" => "English Title", "fr" => "Titre français" })
      assert_equal("Titre français", p.title_fr)
    end
  end

  def test_retrieves_in_specified_locale_with_fallbacks
    I18n::Backend::Simple.include(I18n::Backend::Fallbacks)
    I18n.default_locale = :"en-US"

    p = Post.new(:title_translations => { "en" => "English Title" })
    I18n.with_locale(:fr) do
      assert_equal("English Title", p.title_fr)
    end
  end

  def test_method_missing_delegates
    assert_raise(NoMethodError) { Post.new.nonexistant_method }
  end

  def test_method_missing_delegates_non_translated_attributes
    assert_raise(NoMethodError) { Post.new.other_fr }
  end

  def test_persists_translations_assigned_as_hash
    p = Post.create!(:title_translations => { "en" => "English Title", "fr" => "Titre français" })
    p.reload
    assert_equal({"en" => "English Title", "fr" => "Titre français"}, p.title_translations)
  end

  def test_persists_translations_assigned_to_localized_accessors
    p = Post.create!(:title_en => "English Title", :title_fr => "Titre français")
    p.reload
    assert_equal({"en" => "English Title", "fr" => "Titre français"}, p.title_translations)
  end
end
