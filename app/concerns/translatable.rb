module Translatable
  def i18n_scope
    name.split('::').map(&:underscore)
  end
end
