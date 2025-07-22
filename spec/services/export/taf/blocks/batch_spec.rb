# frozen_string_literal: true

require 'rails_helper'

describe Export::Taf::Blocks::Batch, type: :model do
  let(:organisation) { create(:organisation, :with_accounting) }
  let(:booking) { create(:booking, organisation:, tenant:) }
  let(:vat_category) { create(:vat_category, organisation:, percentage: 50, accounting_vat_code: 'VAT50') }
  let(:tenant) do
    create(:tenant, sequence_number: 200_002, first_name: 'Max', last_name: 'Müller', organisation:,
                    street_address: 'Bahnhofstr. 1', city: 'Bern', zipcode: 1234)
  end

  before do
    organisation.tap { it.accounting_settings.rental_yield_vat_category_id = vat_category.id }.save!
  end

  describe 'JournalEntryBatches::Invoice' do
    subject(:blocks) { Array.wrap(described_class.build_with_journal_entry_batch(journal_entry_batch)) }

    let(:taf) { blocks.map(&:to_s).join("\n\n") }
    let(:invoice) { booking.invoices.last }
    let(:journal_entry_batch) { JournalEntryBatch.where(booking:, invoice:, payment: nil).last }
    let(:booking) do
      create(:booking, :invoiced, tenant:, organisation:, begins_at: '2024-12-20', ends_at: '2024-12-27',
                                  prepaid_amount: 300, vat_category:)
    end

    context 'with invoice_created' do
      it do # rubocop:disable RSpec/ExampleLength
        expect(taf).to eq(<<~TAF.chomp)
          {Adr
            AdrId=200002
            Sort="MAXMUELLER"
            Corp="Max Müller"
            Lang="D"
            Road="Bahnhofstr. 1"
            CCode="CH"
            ACode="1234"
            City="Bern"

          }

          {PKd
            PkKey=200002
            AdrId=200002
            AccId=1050
            ZabId="15T"

          }

          {OPd
            PkKey=200002
            OpId=250001
            ZabId="15T"
            Ref="200002202500001"
            Text="250001 - Müller"

          }

          {Blg
            Date=27.12.2024
            Orig=1

            {Bk
              AccId=1050
              Date=27.12.2024
              Text="250001 - Müller"
              Type=0
              ValNt=420.00
              PkKey=200002
              OpId=250001
              Flags=1

            }

            {Bk
              AccId=6000
              Date=27.12.2024
              TaxId="VAT50"
              Text="250001 - Müller: Saldo aus bereits geleisteten Zahlungen"
              Type=1
              ValNt=-200.00
              ValTx=-100.00
              CAcc=1050
              CIdx=3
              TIdx=4

            }

            {Bk
              AccId=9001
              BType=1
              Date=27.12.2024
              Text="250001 - Müller: Saldo aus bereits geleisteten Zahlungen"
              Type=1
              ValNt=-200.00
              CAcc=6000

            }

            {Bk
              AccId=2016
              BType=2
              CAcc=1050
              Date=27.12.2024
              Text="250001 - Müller: Saldo aus bereits geleisteten Zahlungen"
              Type=1
              ValNt=-100.00
              ValTx=-200.00

            }

            {Bk
              AccId=6000
              Date=27.12.2024
              TaxId="VAT50"
              Text="250001 - Müller: Preis pro Übernachtung"
              Type=1
              ValNt=480.00
              ValTx=240.00
              CAcc=1050
              CIdx=6
              TIdx=7

            }

            {Bk
              AccId=9001
              BType=1
              Date=27.12.2024
              Text="250001 - Müller: Preis pro Übernachtung"
              Type=1
              ValNt=480.00
              CAcc=6000

            }

            {Bk
              AccId=2016
              BType=2
              CAcc=1050
              Date=27.12.2024
              Text="250001 - Müller: Preis pro Übernachtung"
              Type=1
              ValNt=240.00
              ValTx=480.00

            }
          }
        TAF
      end
    end

    context 'with invoice_updated' do
      subject(:blocks) { journal_entry_batches.map { described_class.build_with_journal_entry_batch(it) } }

      let(:journal_entry_batches) { invoice.journal_entry_batches.where(type: JournalEntryBatches::Invoice.sti_name, trigger: %i[invoice_reverted invoice_updated]) }
      let(:date) { Time.zone.today.strftime('%d.%m.%Y') }

      before do
        invoice.journal_entry_batches.reload.update_all(processed_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
        invoice.invoice_parts.last.update(amount: 1440.0)
        invoice.recalculate
        invoice.save!
      end

      it do
        expect(journal_entry_batches).to contain_exactly(
          have_attributes(amount: 420.0, trigger: 'invoice_reverted'),
          have_attributes(amount: 1140.0, trigger: 'invoice_updated')
        )
      end

      it do # rubocop:disable RSpec/ExampleLength
        expect(taf).to eq(<<~TAF.chomp)
          {Blg
            Date=#{date}

            {Bk
              AccId=1050
              Date=#{date}
              Text="250001 - Müller"
              Type=1
              ValNt=420.00
              PkKey=200002
              OpId=250001

            }

            {Bk
              AccId=6000
              Date=#{date}
              TaxId="VAT50"
              Text="250001 - Müller: Saldo aus bereits geleisteten Zahlungen"
              Type=0
              ValNt=-200.00
              ValTx=-100.00
              CAcc=1050
              CIdx=3
              TIdx=4

            }

            {Bk
              AccId=9001
              BType=1
              Date=#{date}
              Text="250001 - Müller: Saldo aus bereits geleisteten Zahlungen"
              Type=0
              ValNt=-200.00
              CAcc=6000

            }

            {Bk
              AccId=2016
              BType=2
              CAcc=1050
              Date=#{date}
              Text="250001 - Müller: Saldo aus bereits geleisteten Zahlungen"
              Type=0
              ValNt=-100.00
              ValTx=-200.00

            }

            {Bk
              AccId=6000
              Date=#{date}
              TaxId="VAT50"
              Text="250001 - Müller: Preis pro Übernachtung"
              Type=0
              ValNt=480.00
              ValTx=240.00
              CAcc=1050
              CIdx=6
              TIdx=7

            }

            {Bk
              AccId=9001
              BType=1
              Date=#{date}
              Text="250001 - Müller: Preis pro Übernachtung"
              Type=0
              ValNt=480.00
              CAcc=6000

            }

            {Bk
              AccId=2016
              BType=2
              CAcc=1050
              Date=#{date}
              Text="250001 - Müller: Preis pro Übernachtung"
              Type=0
              ValNt=240.00
              ValTx=480.00

            }
          }

          {Blg
            Date=#{date}

            {Bk
              AccId=1050
              Date=#{date}
              Text="250001 - Müller"
              Type=0
              ValNt=1140.00
              PkKey=200002
              OpId=250001

            }

            {Bk
              AccId=6000
              Date=#{date}
              TaxId="VAT50"
              Text="250001 - Müller: Saldo aus bereits geleisteten Zahlungen"
              Type=1
              ValNt=-200.00
              ValTx=-100.00
              CAcc=1050
              CIdx=3
              TIdx=4

            }

            {Bk
              AccId=9001
              BType=1
              Date=#{date}
              Text="250001 - Müller: Saldo aus bereits geleisteten Zahlungen"
              Type=1
              ValNt=-200.00
              CAcc=6000

            }

            {Bk
              AccId=2016
              BType=2
              CAcc=1050
              Date=#{date}
              Text="250001 - Müller: Saldo aus bereits geleisteten Zahlungen"
              Type=1
              ValNt=-100.00
              ValTx=-200.00

            }

            {Bk
              AccId=6000
              Date=#{date}
              TaxId="VAT50"
              Text="250001 - Müller: Preis pro Übernachtung"
              Type=1
              ValNt=960.00
              ValTx=480.00
              CAcc=1050
              CIdx=6
              TIdx=7

            }

            {Bk
              AccId=9001
              BType=1
              Date=#{date}
              Text="250001 - Müller: Preis pro Übernachtung"
              Type=1
              ValNt=960.00
              CAcc=6000

            }

            {Bk
              AccId=2016
              BType=2
              CAcc=1050
              Date=#{date}
              Text="250001 - Müller: Preis pro Übernachtung"
              Type=1
              ValNt=480.00
              ValTx=960.00

            }
          }
        TAF
      end
    end

    describe 'JournalEntryBatches::Payment' do
      let(:booking) do
        create(:booking, :invoiced, tenant:, organisation:, begins_at: '2024-12-20', ends_at: '2024-12-27')
      end
      let(:invoice) { booking.invoices.last }
      let(:payment) { Payment.create!(booking:, invoice:, amount: 999.99, paid_at: '2024-12-24', write_off: false) }
      let(:journal_entry_batch) { JournalEntryBatch.where(booking:, invoice:, payment:).last }

      before do
        invoice.update!(sequence_year: 2024, ref: nil)
        JournalEntryBatch.where(booking:, invoice:, payment: nil).update_all(processed_at: 1.month.ago) # rubocop:disable Rails/SkipsModelValidations
      end

      context 'with payment_created' do
        it do # rubocop:disable RSpec/ExampleLength
          expect(taf).to eq(<<~TAF.chomp)
            {Blg
              Date=24.12.2024
              Orig=1

              {Bk
                AccId=1050
                Date=24.12.2024
                Text="Zahlung 240001"
                Type=1
                ValNt=999.99
                PkKey=#{booking.tenant.ref}
                OpId=240001

              }

              {Bk
                AccId=1025
                Date=24.12.2024
                Text="Zahlung 240001"
                Type=0
                ValNt=999.99
                CAcc=1050

              }
            }
          TAF
        end
      end

      context 'with payment_created and negative amount' do
        let(:payment) { Payment.create!(booking:, invoice:, amount: -300.0, paid_at: '2024-12-24', write_off: false) }

        it do # rubocop:disable RSpec/ExampleLength
          expect(taf).to eq(<<~TAF.chomp)
            {Blg
              Date=24.12.2024
              Orig=1

              {Bk
                AccId=1050
                Date=24.12.2024
                Text="Zahlung 240001"
                Type=0
                ValNt=300.00
                PkKey=#{booking.tenant.ref}
                OpId=240001

              }

              {Bk
                AccId=1025
                Date=24.12.2024
                Text="Zahlung 240001"
                Type=1
                ValNt=300.00
                CAcc=1050

              }
            }
          TAF
        end
      end
    end
  end
end
