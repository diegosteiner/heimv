class MoveToNewReadonlyRole < ActiveRecord::Migration[6.1]
  def change
    User.role_tenant.each(&:role_readonly!)
  end
end
