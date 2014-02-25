require 'active_record'
require 'active_record/connection_adapters/postgresql_adapter'
require 'hstore_translate/translates'
require 'hstore_translate/active_record_extensions'

module HstoreTranslate
  def self.native_hstore?
    @native_hstore ||= ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES.key?(:hstore)
  end
end

require 'activerecord-postgres-hstore' unless HstoreTranslate::native_hstore?

ActiveRecord::Base.extend(HstoreTranslate::Translates)
