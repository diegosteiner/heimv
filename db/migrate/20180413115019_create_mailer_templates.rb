class CreateMailerTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :mailer_templates do |t|
      t.string :mailer
      t.string :action
      t.string :locale
      t.string :subject
      t.text :body

      t.timestamps
    end
  end
end
