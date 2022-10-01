class DropOffers < ActiveRecord::Migration[7.0]
  def up
    drop_table :offers

    RichTextTemplate.where(key: 'offer_text').update_all(key: 'invoices_offer_text')
  end
end
