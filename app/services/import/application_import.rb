# frozen_string_literal: true

module Import
  class ApplicationImport
    include ActiveModel::Model
    extend ActiveModel::Naming
    extend ActiveModel::Translation
    include ActiveModel::Attributes
    include ActiveModel::Validations

    delegate :ok?, to: :result

    attribute :file
    attribute :headers
    attribute :organisation

    validates :file, presence: true

    def import!; end

    def result
      @result ||= import!
    end
  end
end
