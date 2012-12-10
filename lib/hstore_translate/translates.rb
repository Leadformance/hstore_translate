module HstoreTranslate
  def translates(*attrs)
    include InstanceMethods

    class_attribute :translated_attrs
    self.translated_attrs = attrs

    attrs.each do |attr_name|
      serialize "#{attr_name}_translations", ActiveRecord::Coders::Hstore

      class_eval <<-RUBY
        def #{attr_name}
          read_hstore_translation('#{attr_name}')
        end

        def #{attr_name}=(value)
          write_hstore_translation('#{attr_name}', value)
        end
      RUBY
    end

    alias_method_chain :method_missing, :translates
  end

  module InstanceMethods
    protected

    def read_hstore_translation(attr_name, locale = I18n.locale)
      translations = send("#{attr_name}_translations") || {}
      translation  = translations[locale.to_s]

      if translation.nil? && I18n.respond_to?(:fallbacks) && (fallbacks = I18n.fallbacks[locale])
        fallbacks.find { |f| translation = translations[f.to_s] }
      end

      translation
    end

    def write_hstore_translation(attr_name, value, locale = I18n.locale)
      translation_store = "#{attr_name}_translations"
      translations = send(translation_store) || {}
      translations[locale.to_s] = value
      send("#{translation_store}=", translations)
      value
    end

    def method_missing_with_translates(method_name, *args)
      return method_missing_without_translates(method_name, *args) unless
        method_name =~ /\A([a-z_]+)_([a-z]{2,2})(=?)\z/ &&
        (attr_name = $1.to_sym) && translated_attrs.include?(attr_name)

      locale    = $2.to_sym
      assigning = $3.present?

      if assigning
        write_hstore_translation(attr_name, args.first, locale)
      else
        read_hstore_translation(attr_name, locale)
      end
    end
  end
end
