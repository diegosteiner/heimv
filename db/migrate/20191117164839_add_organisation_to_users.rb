class AddOrganisationToUsers < ActiveRecord::Migration[6.0]
  def change
    organisation = Organisation.first

    add_reference :users, :organisation, null: false, default: organisation&.id, foreign_key: true
    add_reference :data_digests, :organisation, null: false, default: organisation&.id, foreign_key: true
    add_reference :booking_agents, :organisation, null: false, default: organisation&.id, foreign_key: true
    add_reference :markdown_templates, :organisation, null: false, default: organisation&.id, foreign_key: true
    add_reference :tenants, :organisation, null: false, default: organisation&.id, foreign_key: true

    # if organisation.present?
    #   User.update_all(organisation_id: organisation.id)
    #   DataDigest.update_all(organisation_id: organisation.id)
    #   BookingAgent.update_all(organisation_id: organisation.id)
    #   MarkdownTemplate.update_all(organisation_id: organisation.id)
    #   Tenant.update_all(organisation_id: organisation.id)
    # end
  end
end
