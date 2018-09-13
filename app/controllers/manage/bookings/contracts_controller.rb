module Manage
  module Bookings
    class ContractsController < BaseController
      load_and_authorize_resource :booking
      load_and_authorize_resource :contract, through: :booking

      layout false, only: :show

      # before_action do
      #   breadcrumbs.add(Booking.model_name.human(count: :other), manage_bookings_path)
      #   breadcrumbs.add(@booking, manage_booking_path(@booking))
      #   breadcrumbs.add(Contract.model_name.human(count: :other), manage_booking_contracts_path)
      # end
      # before_action(only: :new) { breadcrumbs.add(t(:new)) }
      # before_action(only: %i[show edit]) { breadcrumbs.add(@contract.to_s,
      # manage_booking_contract_path(@booking, @contract)) }
      # before_action(only: :edit) { breadcrumbs.add(t(:edit)) }

      def index
        respond_with :manage, @contracts
      end

      # rubocop:disable Metrics/MethodLength
      def new
        @contract.text = <<~EOTEXT
          ##### Allgemein
          Der Vermieter überlässt dem Mieter das Pfadiheim Birchli in Einsiedeln für den nachfolgend aufgeführten Anlass zur alleinigen Benutzung

          ##### Mietdauer
          **Mietbeginn**: %<booking_occupancy_begins_at>s
          **Mietende**: %<booking_occupancy_ends_at>s

          Die Hausübergabe bzw. –rücknahme erfolgt durch den Heimwart. Der Mieter hat das Haus persönlich zum vereinbarten Zeitpunkt zu übernehmen resp. zu übergeben. Hierfür sind jeweils ca. 30 Minuten einzuplanen. Die Übernahme- und Rückgabezeiten sind unbedingt einzuhalten.

          Verspätungen ab 15 Minuten werden mit CHF 20.- pro angebrochene Viertelstunde verrechnet!

          Der genaue Zeitpunkt der Hausübernahme ist mit dem Heimwart spätestens 5 Tage vor Mietbeginn telefonisch zu vereinbaren:

          * %<booking_home_janitor>s

          ##### Übernahme und Rückgabe
          Die Übernahme- und Rückgabezeiten sind unbedingt einzuhalten. Verspätungen ab 15 Minuten werden mit CHF 20.- pro angebrochene Viertelstunde verrechnet!

          ##### Zweck der Miete
          (durch den Mieter auszufüllen)
          ___________________________________________________________________
          ___________________________________________________________________

          ##### Tarife
          Die Mindestbelegung beträgt durchschnittlich 12 Personen pro Nacht.

          ##### Anzahlung
          Die Anzahlung wird bei Abschluss des Vertrages fällig

        EOTEXT

        respond_with :manage, @booking, @contract
      end
      # rubocop:enable Metrics/MethodLength

      def show
        respond_to do |format|
          format.html
          format.pdf do
            pdf = ContractPdf.new(@contract).build
            send_data(pdf.render, filename: @contract.filename, content_type: 'application/pdf')
          end
        end
      end

      def edit
        respond_with :manage, @contract
      end

      def create
        @contract.valid_from = Time.zone.now
        @contract.save
        respond_with :manage, @contract, location: manage_booking_contracts_path(@booking)
      end

      def update
        @contract.update(contract_params)
        respond_with :manage, @contract, location: manage_booking_contracts_path(@booking)
      end

      def destroy
        @contract.destroy
        respond_with :manage, @contract, location: manage_booking_contracts_path(@booking)
      end

      private

      def contract_params
        ContractParams.permit(params.require(:contract))
      end
    end
  end
end
