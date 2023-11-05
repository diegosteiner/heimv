# frozen_string_literal: true

module TemplateRenderable
  def to_partial_path(*)
    File.join('renderables', self.class.to_s.underscore, *)
  end
end
