class AddGroupToDataDigests < ActiveRecord::Migration[7.0]
  def change
    add_column :data_digests, :group, :string, null: true
    remove_column :data_digests, :data_digest_params, :jsonb, default: {}
    remove_column :organisations, :notification_footer, :text, null: true, if_exists: true
    # change_column_default :users, :default_organisation_id, from: 1, to: nil

    reversible do |direction|
      direction.up do 
        DataDigest.find_each do |data_digest|
          homes = Home.where(id: data_digest.prefilter_params.dig("homes"), organisation: data_digest.organisation)
          next unless homes.count == 1

          data_digest.update(group: homes.take.name)
        end
      end
    end
  end
end
