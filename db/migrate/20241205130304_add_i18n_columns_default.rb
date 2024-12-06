class AddI18nColumnsDefault < ActiveRecord::Migration[8.0]
  def change
    # BookableExtra.where(title_i18n: nil).update_all(title_i18n: {})
    # change_column :bookable_extras, :title_i18n, :jsonb, default: {}, null: false
    # BookableExtra.where(description_i18n: nil).update_all(description_i18n: {})
    # change_column :bookable_extras, :description_i18n, :jsonb, default: {}, null: false

    BookingCategory.where(title_i18n: nil).update_all(title_i18n: {})
    change_column :booking_categories, :title_i18n, :jsonb, default: {}, null: false
    BookingCategory.where(description_i18n: nil).update_all(description_i18n: {})
    change_column :booking_categories, :description_i18n, :jsonb, default: {}, null: false
    BookingQuestion.where(label_i18n: nil).update_all(label_i18n: {})
    change_column :booking_questions, :label_i18n, :jsonb, default: {}, null: false
    BookingQuestion.where(description_i18n: nil).update_all(description_i18n: {})
    change_column :booking_questions, :description_i18n, :jsonb, default: {}, null: false
    BookingValidation.where(error_message_i18n: nil).update_all(error_message_i18n: {})
    change_column :booking_validations, :error_message_i18n, :jsonb, default: {}, null: false
    Occupiable.where(name_i18n: nil).update_all(name_i18n: {})
    change_column :occupiables, :name_i18n, :jsonb, default: {}, null: false
    Occupiable.where(description_i18n: nil).update_all(description_i18n: {})
    change_column :occupiables, :description_i18n, :jsonb, default: {}, null: false
    VatCategory.where(label_i18n: nil).update_all(label_i18n: {})
    change_column :vat_categories, :label_i18n, :jsonb, default: {}, null: false
  end
end
