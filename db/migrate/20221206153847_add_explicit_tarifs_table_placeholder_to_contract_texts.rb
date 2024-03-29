class AddExplicitTarifsTablePlaceholderToContractTexts < ActiveRecord::Migration[7.0]
  def up
    Contract
    RichTextTemplate.where(key: :contract_text).find_each do |rtt|
      rtt.body_i18n.each do |locale, body|
        next if body.blank?

        rtt.send("body_#{locale}=", body + "\n#{Export::Pdf::ContractPdf::TARIFS_TABLE_PLACEHOLDER}")
      end
      rtt.save!
    end
  end
end
