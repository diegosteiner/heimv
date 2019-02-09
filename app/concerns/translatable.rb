module Translatable
  def i18n_scope
    self.name.split('::').map(&:underscore)
  end
end
