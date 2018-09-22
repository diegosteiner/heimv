require 'prawn'

module Pdf
  class BasePdf
    include Prawn::View

    def document
      @document ||= Prawn::Document.new(
        page_size: 'A4',
        optimize_objects: true,
        margin: [50] * 4,
        align: :left, kerning: true
      )
    end

    def build
      sections.each { |section| section.call(document) }
      self
    end
  end
end
