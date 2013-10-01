module HstoreTranslate
  module Translates
    def translates(*attrs)
      include InstanceMethods

      class_attribute :translated_attrs
      self.translated_attrs = attrs

      attrs.each do |attr_name|
        serialize "#{attr_name}_translations", ActiveRecord::Coders::Hstore unless HstoreTranslate::native_hstore?

        define_method attr_name do
          read_hstore_translation(attr_name)
        end
        
        define_method "#{attr_name}=" do |value|
          write_hstore_translation(attr_name, value)
        end
        
        define_singleton_method "find_by_#{attr_name}" do |value|
          find_hstore_translation(attr_name, value)
        end
      end

      alias_method_chain :respond_to?, :translates
      alias_method_chain :method_missing, :translates
    end

    module InstanceMethods
      def disable_fallback
        @disable_fallback = true
      end

      def enable_fallback
        @disable_fallback = false
      end

      protected

      def hstore_translate_fallback_locales(locale)
        return if !!@disable_fallback || !I18n.respond_to?(:fallbacks)
        I18n.fallbacks[locale]
      end

      def read_hstore_translation(attr_name, locale = I18n.locale)
        translations = send("#{attr_name}_translations") || {}
        translation  = translations[locale.to_s]

        if fallback_locales = hstore_translate_fallback_locales(locale)
          fallback_locales.each do |fallback_locale|
            t = translations[fallback_locale.to_s]
            if t && !t.empty? # differs from blank?
              translation = t
              break
            end
          end
        end

        translation
      end

      def write_hstore_translation(attr_name, value, locale = I18n.locale)
        translation_store = "#{attr_name}_translations"
        translations = send(translation_store) || {}
        send("#{translation_store}_will_change!") unless translations[locale.to_s] == value
        translations[locale.to_s] = value
        send("#{translation_store}=", translations)
        value
      end

      def respond_to_with_translates?(symbol, include_all = false)
        return true if parse_translated_attribute_accessor(symbol)
        respond_to_without_translates?(symbol, include_all)
      end

      def method_missing_with_translates(method_name, *args)
        translated_attr_name, locale, assigning = parse_translated_attribute_accessor(method_name)

        return method_missing_without_translates(method_name, *args) unless translated_attr_name

        if assigning
          write_hstore_translation(translated_attr_name, args.first, locale)
        else
          read_hstore_translation(translated_attr_name, locale)
        end
      end

      def parse_translated_attribute_accessor(method_name)
        return unless method_name =~ /\A([a-z_]+)_([a-z]{2})(=?)\z/

        translated_attr_name = $1.to_sym
        return unless translated_attrs.include?(translated_attr_name)

        locale    = $2.to_sym
        assigning = $3.present?

        [translated_attr_name, locale, assigning]
      end
    end
    
    def find_hstore_translation(attr_name, value, locale = I18n.locale)
      quoted_translation_store = connection.quote_column_name("#{attr_name}_translations")
      where("#{quoted_translation_store} @> hstore(:locale, :value)", locale: locale, value: value).first
    end
  end
end
