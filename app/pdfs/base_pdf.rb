require 'prawn'

class BasePdf
  include Prawn::View
  class_attribute :parts, instance_accessor: false, default: {}

  def self.part(name, &block)
    parts[name] = block if block_given?
  end

  def document
    @document ||= Prawn::Document.new(
      page_size: 'A4',
      optimize_objects: true,
      margin: [50] * 4,
      align: :left, kerning: true
    )
    # font_families.update("OCR" => {
    # :normal => Rails.root.join("app/assets/fonts/OpenSans-Regular.ttf"),
    # })
  end

  def build
    self.class.parts.values.each { |part| instance_eval(&part) }
    self
  end

  part :header do |_doc|
    image Rails.root.join('app', 'webpack', 'images', 'logo_hvs.png'),
          at: [bounds.top_left[0], bounds.top_left[1] + 35],
          width: 120
  end
end
