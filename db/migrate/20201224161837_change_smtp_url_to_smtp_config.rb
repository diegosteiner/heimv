class ChangeSmtpUrlToSmtpConfig < ActiveRecord::Migration[6.1]
  def change
    add_column :organisations, :smtp_settings, :jsonb, null: true

    reversible do |direction|
      direction.up do
        Organisation.find_each do |organisation|
          organisation.update!(smtp_settings: JSON.parse(organisation.smtp_url)) if organisation.smtp_settings.present?
        end
      end
    end
    remove_column :organisations, :smtp_url, :text
  end
end
