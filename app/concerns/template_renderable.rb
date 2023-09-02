# frozen_string_literal: true

module TemplateRenderable
  def to_partial_path(*template)
    File.join('renderables', self.class.to_s.underscore, *template)
  end
end
