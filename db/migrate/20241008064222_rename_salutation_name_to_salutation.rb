class RenameSalutationNameToSalutation < ActiveRecord::Migration[7.2]
  def change
    Organisation.find_each do |organisation|
      rtts = RichTextTemplateService.new(organisation)
      replace = "tenant.salutation }}"
      rtts.replace_in_template!("tenant.salutation_name}}", replace)
      rtts.replace_in_template!("tenant.salutation_name }}", replace)
    end
  end
end
