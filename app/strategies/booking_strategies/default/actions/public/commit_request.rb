module BookingStrategies
  class Default
    module Actions
      module Public
        class CommitRequest < BookingStrategy::Action
          def call!
            @booking.update(committed_request: true)
          end

          def allowed?
            @booking.valid?(context: :public_update) &&
              @booking.state_machine.in_state?(:provisional_request) &&
              !@booking.committed_request
          end

          def button_options
            super.merge(
              variant: 'primary'
            )
          end
        end
      end
    end
  end
end
