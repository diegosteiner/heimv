# frozen_string_literal: true

# == Schema Information
#
# Table name: offers
#
#  id          :bigint           not null, primary key
#  text        :text
#  valid_from  :datetime
#  valid_until :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  booking_id  :uuid
#
# Indexes
#
#  index_offers_on_booking_id  (booking_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#
class Offer < ApplicationRecord
  RichTextTemplate.require_template(:offer_text, %i[booking], self)

  belongs_to :booking, inverse_of: :offers
  has_one_attached :pdf

  scope :ordered, -> { order(valid_from: :asc) }

  before_save :generatate_pdf

  def generatate_pdf
    self.pdf = {
      io: StringIO.new(Export::Pdf::OfferPdf.new(self).render_document),
      filename: filename,
      content_type: 'application/pdf'
    }
  end

  def filename
    "#{self.class.model_name.human}_#{booking.ref}_#{id}.pdf"
  end
end
