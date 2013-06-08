# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hstore_translate/version"

Gem::Specification.new do |s|
  s.name              = 'hstore_translate'
  s.version           = HstoreTranslate::VERSION
  s.summary           = "Rails I18n library for ActiveRecord model/data translation using PostgreSQL's hstore datatype."
  s.description       = "#{s.summary} Translations are stored directly in the model table rather than shadow tables."
  s.authors           = ["Rob Worley"]
  s.email             = 'robert.worley@gmail.com'
  s.homepage          = "https://github.com/robworley/hstore_translate"
  s.files             = Dir['{lib/**/*,[A-Z]*}']
  s.platform          = Gem::Platform::RUBY
  s.require_paths     = ["lib"]
  s.rubyforge_project = '[none]'

  if ENV['RAILS_3_1']
    s.add_dependency 'activerecord', '~> 3.1.0'
  elsif ENV['RAILS_3_2']
    s.add_dependency 'activerecord', '~> 3.2.0'
  elsif ENV['RAILS_4']
    s.add_dependency 'activerecord', '4.0.0.rc1'
  else
    s.add_dependency 'activerecord', '>= 3.1.0'
  end

  s.add_dependency 'pg'
  s.add_dependency 'activerecord-postgres-hstore', '~> 0.7.0'

  s.add_development_dependency 'rake'
end
