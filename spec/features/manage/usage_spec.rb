# frozen_string_literal: true

require 'rails_helper'

describe 'Usage', :devise do
  let(:organisation) { create(:organisation, :with_templates) }
  let(:org) { organisation.to_param }
  let(:organisation_user) { create(:organisation_user, :admin, organisation:) }
  let(:booking) { create(:booking, organisation:) }
  let(:tarifs) do
    [
      create(:tarif, :amount, organisation:),
      create(:tarif, :metered, organisation:),
      create(:tarif, :overnight_stay, label: 'Übernachtung (U16)', tarif_group: 'Übernachtungen',
                                      prefill_usage_method: :headcount, organisation:),
      create(:tarif, :overnight_stay, label: 'Übernachtung (Ü16)', tarif_group: 'Übernachtungen',
                                      prefill_usage_method: :headcount, organisation:),
      create(:tarif, :group_minimum, label: 'Mindestbelegung', tarif_group: 'Übernachtungen', organisation:),
      create(:tarif, :price, label: 'Schaden', organisation:)
    ]
  end

  before do
    signin(organisation_user.user, organisation_user.user.password)
  end

  it 'saves all selected tarifs as usages' do
    tarifs
    visit manage_booking_usages_path(booking, org:)
    select_tarifs
    expect(booking.reload.usages.pluck(:tarif_id)).to match_array(tarifs.map(&:id))
  end

  it 'allows to use overnight_stay and group_minimum' do # rubocop:disable RSpec/ExampleLength
    tarifs
    visit manage_booking_usages_path(booking, org:)
    select_tarifs(tarifs[2..4])

    booking.usages.find_by(tarif: tarifs[2]).tap do |usage|
      find_usage_form_field(usage, :summary).fill_in(with: 2)
    end

    booking.usages.find_by(tarif: tarifs[3]).tap do |usage|
      find_usage_form_field(usage, :toggle).click
      usage.booking_dates.each_with_index do |detail, index|
        find_usage_form_field(usage, :detail, detail).fill_in(with: index)
      end
      find_usage_form_field(usage, :toggle).click
      expect(find_usage_form_field(usage, :summary).value).to eq('0 … 6')
    end

    submit_form
    expect(page).to have_text I18n.t('flash.actions.update.notice', resource_name: Usage.model_name.human)
    total = booking.usages.reload.to_a.sum(&:price)
    # if total = 1050.0
    expect(total).to eq(1050.0)
    # else
    #   binding.irb
    # end
  end

  def find_usage_form_field(usage, field, detail = nil)
    find case field
         when :summary
           "input[name='usages[#{usage.id}][summary]']"
         when :toggle
           "button[name='usages[#{usage.id}][toggle_details]']"
         when :detail
           "input[name='usages[#{usage.id}][details][#{detail}]']"
         end
  end

  def select_tarifs(tarifs = self.tarifs)
    tarifs.each do |tarif|
      find('label', text: tarif.label).click
    end
    submit_form
    expect(page).to have_text I18n.t('manage.bookings.usages.index.applicable_tarifs') # wait for page to load
  end
end
