module TemplateRenderable
  def template_path(*template)
    File.join(self.class.to_s.underscore, *template)
  end
end
