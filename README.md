# hstore_translate

Development of this library is continuing at <https://github.com/cfabianski/json_translate>.

Rails I18n library for ActiveRecord model/data translation using PostgreSQL's
hstore datatype. It provides an interface inspired by
[Globalize3](https://github.com/svenfuchs/globalize3) but removes the need to
maintain separate translation tables.

[![Build Status](https://api.travis-ci.org/robworley/hstore_translate.png)](https://travis-ci.org/robworley/hstore_translate)
[![License](http://img.shields.io/badge/license-mit-brightgreen.svg)](COPYRIGHT)
[![Code Climate](https://codeclimate.com/github/robworley/hstore_translate.png)](https://codeclimate.com/github/robworley/hstore_translate)

## Requirements

* ActiveRecord > 3.1.0 (4+ for JRuby)
* I18n

## Installation

gem install hstore_translate

When using bundler, put it in your Gemfile:

```ruby
source 'https://rubygems.org'

gem 'activerecord'
gem 'pg', :platform => :ruby
gem 'activerecord-jdbcpostgresql-adapter', :platform => :jruby
gem 'hstore_translate'
```

For ActiveRecord < 4.0 you'll also want to add:

```ruby
gem 'activerecord-postgres-hstore', '~> 0.7.0'
```

## Model translations

Model translations allow you to translate your models' attribute values. E.g.

```ruby
class Post < ActiveRecord::Base
  translates :title, :body
end
```

Allows you to translate the attributes :title and :body per locale:

```ruby
I18n.locale = :en
post.title # => This database rocks!

I18n.locale = :he
post.title # => אתר זה טוב
```

You also have locale-specific convenience methods from [easy_globalize3_accessors](https://github.com/paneq/easy_globalize3_accessors):

```ruby
I18n.locale = :en
post.title # => This database rocks!
post.title_he # => אתר זה טוב
```

To find records using translations without constructing hstore queries by hand:

```ruby
Post.with_title_translation("This database rocks!") # => #<ActiveRecord::Relation ...>
Post.with_title_translation("אתר זה טוב", :he) # => #<ActiveRecord::Relation ...>
```

In order to make this work, you'll need to define an hstore column for each of
your translated attributes, using the suffix "_translations":

```ruby
class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.hstore :title_translations
      t.hstore :body_translations
      t.timestamps
    end

    # It only works with Rails 4.
    add_index :posts, :title_translations, using: :gin
    add_index :posts, :body_translations, using: :gin
  end
end
```

## I18n fallbacks for missing translations

It is possible to enable fallbacks for missing translations. It will depend
on the configuration setting you have set for I18n translations in your Rails
config.

You can enable them by adding the next line to `config/application.rb` (or
only `config/environments/production.rb` if you only want them in production)

```ruby
config.i18n.fallbacks = true
```

Sven Fuchs wrote a [detailed explanation of the fallback
mechanism](https://github.com/svenfuchs/i18n/wiki/Fallbacks).

## Temporarily disable fallbacks

If you've enabled fallbacks for missing translations, you probably want to disable
them in the admin interface to display which translations the user still has to
fill in.

From:

```ruby
I18n.locale = :en
post.title # => This database rocks!
post.title_nl # => This database rocks!
```

To:

```ruby
I18n.locale = :en
post.title # => This database rocks!
post.disable_fallback
post.title_nl # => nil
```

You can also call your code into a block that temporarily disable or enable fallbacks.

```ruby
I18n.locale = :en
post.title_nl # => This database rocks!

post.disable_fallback do
  post.title_nl # => nil
end

post.disable_fallback
post.enable_fallback do
  post.title_nl # => This database rocks!
end
```
