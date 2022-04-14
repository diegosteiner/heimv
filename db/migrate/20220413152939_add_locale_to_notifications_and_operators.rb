class AddLocaleToNotificationsAndOperators < ActiveRecord::Migration[7.0]
  def change
    add_column :notifications, :locale, :string, null: false, default: I18n.default_locale
    add_column :operators, :locale, :string, null: false, default: I18n.default_locale
    add_column :tenants, :locale, :string, null: false, default: I18n.default_locale

    # reversible { direction.up set_locales }

    # remove_column :bookings, :locale, :string, null: false, default: I18n.default_locale
  end

  private

  def set_locales
    Booking.find_each do |booking|
      next if booking.tenant.blank?

      booking.tenant.update(locale: booking.locale)
    end
  end
end
