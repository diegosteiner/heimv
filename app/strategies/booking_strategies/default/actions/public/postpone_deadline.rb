module BookingStrategies
  class Default
    module Actions
      module Public
        class PostponeDeadline < BookingStrategy::Action
          def call!
            return booking.deadline.postpone if booking.deadline.postponable_until < booking.occupancy.begins_at

            booking.errors.add(:deadline, :not_postponable)
          end

          def allowed?
            booking.deadline&.postponable?
          end

          def button_options
            super.merge(
              variant: 'secondary'
            )
          end

          def booking
            context.fetch(:booking)
          end

          private

          def new_deadline_at
            booking.organisation.long_deadline.from_now
          end
        end
      end
    end
  end
end
