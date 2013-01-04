require "active_record/connection_adapters/postgresql_adapter"
require "hstore_translate/translates"
require "hstore_translate/version"

module HstoreTranslate
  def self.native_hstore?
    @native_hstore ||= ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES.key?(:hstore)
  end
end

ActiveRecord::Base.extend(HstoreTranslate::Translates)
