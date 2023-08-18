class MigrateExtrasToBookingQuestions < ActiveRecord::Migration[7.0]
  def up
    BookableExtra.transaction do
      Organisation.find_each do |organisation|
        organisation.bookable_extras.each_with_index do |bookable_extra, i|
          booking_question = create_booking_question(organisation, bookable_extra, index: i)
          create_booking_question_responses(bookable_extra, booking_question)
          update_booking_conditions(organisation, bookable_extra, booking_question)
        end
      end 
    end
  end

  def down
  end

  protected

  def create_booking_question(organisation, bookable_extra, index: nil)
    organisation.booking_questions.create!(label_i18n: bookable_extra.title_i18n, 
                                          description_i18n: bookable_extra.description_i18n,
                                          type: BookingQuestions::CheckBox.to_s, 
                                          required: false, ordinal: index)
  end

  def create_booking_question_responses(bookable_extra, booking_question)
    BookedExtra.where(bookable_extra: bookable_extra).map do |booked_extra|
      booked_extra.booking.booking_question_responses.create!(booking_question: booking_question, value: true)
    end
  end

  def update_booking_conditions(organisation, bookable_extra, booking_question)
    BookingConditions::BookableExtra.where(organisation: organisation, compare_value: bookable_extra.id).map do |bec|
      bec.becomes(BookingConditions::BookingQuestion).update!(type: BookingConditions::BookingQuestion.to_s,
                                                             compare_operator: :'=',
                                                             compare_value: true, 
                                                             compare_attribute: booking_question.id)
    end
  end
end
