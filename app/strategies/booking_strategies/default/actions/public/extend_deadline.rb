module BookingStrategies
  class Default
    module Actions
      module Public
        class ExtendDeadline < BookingStrategy::Action
          def call!
            return booking.errors.add(:deadline, :not_extendable) if new_deadline_at > booking.occupancy.begins_at

            booking.deadline.extend_until(new_deadline_at)
          end

          def allowed?
            booking.deadline&.extendable?
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
