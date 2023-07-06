# frozen_string_literal: true

module TemplateRenderable
  def template_path(*template)
    File.join('renderables', self.class.to_s.underscore, *template)
  end
end
