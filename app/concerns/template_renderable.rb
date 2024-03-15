# frozen_string_literal: true

module TemplateRenderable
  def to_partial_path(*)
    partial_path = is_a?(Class) ? to_s.underscore : self.class.to_s.underscore
    File.join('renderables', partial_path, *)
  end
end
