require 'prawn'

module Pdf
  class Base
    include Prawn::View

    def document
      @document ||= Prawn::Document.new(
        page_size: 'A4',
        optimize_objects: true,
        compress: true,
        margin: [50] * 4,
        align: :left, kerning: true
      )
      @document.font_size(10)
      @document.font_families.update("Arial" => {
        normal: Rails.root.join("app/webpack/fonts/OpenSans-Regular.ttf"),
        italic: Rails.root.join("app/webpack/fonts/OpenSans-Regular.ttf"),
        bold: Rails.root.join("app/webpack/fonts/OpenSans-Regular.ttf"),
        bold_italic: Rails.root.join("app/webpack/fonts/OpenSans-Regular.ttf")
      })
      @document.font "Arial"
      @document
    end

    def build
      sections.each { |section| section.call(document) }
      self
    end
  end
end
