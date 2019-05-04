class Report < ApplicationRecord
  include TemplateRenderable

  def to_s
    self.class.to_s
  end

  def formats
    self.class.formats.keys
  end

  class << self
    attr_reader :formats

    def format(format_name, &block)
      @formats ||= {}
      @formats[format_name] = block
    end
  end

  def in_format(format)
    instance_exec self.class.formats[format]
  end
end
