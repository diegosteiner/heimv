class RenameLiquidI18nLocalizeToDatetimeFormat < ActiveRecord::Migration[6.0]
  def up 
    MarkdownTemplate.find_each do |template| 
      template.body&.gsub!('| i18n_localize', '| datetime_format')
      template.save
    end
  end
end
