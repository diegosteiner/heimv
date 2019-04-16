module Translatable
  def i18n_scope
    self.class.name.split('::').map(&:underscore)
  end
end
