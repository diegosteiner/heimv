module Admin
  class UserParams < ApplicationParams
    def self.permitted_keys
      %i[email role]
    end
  end
end
