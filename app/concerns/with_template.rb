module WithTemplate
  def template_path(template)
    File.join(to_s.underscore, template)
  end
end
