module HstoreTranslate
  module ActiveRecordExtensions

    module ClassMethods

      def validates_hstore_translate(*attributes)
        options = {
          presence: false,
          length: { allow_blank: false },
          format: {}
        }.merge(attributes.extract_options!)

        options.assert_valid_keys([:presence, :length, :format])

        attributes.each do |attribute|
          I18n.available_locales.each do |locale|
            if options[:presence]
              module_eval do
                validates "#{attribute}_#{locale}", presence: true
              end
            end

            if options[:length]
              module_eval do
                if options[:length][:minimum]
                  validates "#{attribute}_#{locale}", length: { minimum: options[:length][:minimum] },
                    allow_blank: options[:length][:allow_blank]
                end
                if options[:length][:maximum]
                  validates "#{attribute}_#{locale}", length: { maximum: options[:length][:maximum] },
                    allow_blank: options[:length][:allow_blank]
                end
              end
            end

            if options[:format]
              module_eval do
                validates "#{attribute}_#{locale}", format: { with: options[:format][:with] }
              end
            end
          end
        end
      end

    end
  end
end

ActiveRecord::Base.extend HstoreTranslate::ActiveRecordExtensions::ClassMethods
