# frozen_string_literal: true

module Import
  module Hash
    class RichTextTemplateImporter < Base
      attr_reader :organisation

      use_attributes(*%w[key title_i18n body_i18n home_id enabled])

      def initialize(organisation, **options)
        super(**options)
        @organisation = organisation
      end

      def initialize_record(hash)
        organisation.rich_text_templates.find_or_initialize_by(hash.slice('key', 'home_id'))
      end
    end
  end
end
