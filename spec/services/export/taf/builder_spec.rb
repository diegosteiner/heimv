# frozen_string_literal: true

require 'rails_helper'

describe Export::Taf::Builder, type: :model do
  let(:organisation) { create(:organisation, :with_accounting) }
  let(:booking) { create(:booking, organisation:, tenant:) }
  let(:vat_category) { create(:vat_category, organisation:, percentage: 50, accounting_vat_code: 'VAT50') }
  let(:tenant) do
    create(:tenant, sequence_number: 200_002, first_name: 'Max', last_name: 'Müller', organisation:,
                    street_address: 'Bahnhofstr. 1', city: 'Bern', zipcode: 1234)
  end

  subject(:builder) { described_class.new }
  subject(:blocks) { builder.blocks }

  describe '#journal_entry' do
    before { builder.journal_entry(journal_entry) }
    let(:journal_entry) do
      create(:journal_entry, booking:, date: Date.new(2024, 10, 5), ref: '1234', amount: 2091.75,
                             vat_category_id: vat_category.id,
                             text: "Lorem ipsum\nSecond Line, but its longer than sixty \"chars\", OMG!")
    end

    it 'builds correctly' do
      is_expected.to all(be_a(Export::Taf::Block))
      expect(blocks.first.to_s).to eq(<<~TAF.chomp)
        {Blg
          Date=05.10.2024

          {Bk
            AccId=1050
            Date=05.10.2024
            TaxId="VAT50"
            Text="Lorem ipsum"
            Text2="Second Line, but its longer than sixty ""chars"", "
            Type=0
            ValNt=2091.75

          }

          {Bk
            AccId=6000
            Date=05.10.2024
            TaxId="VAT50"
            Text="Lorem ipsum"
            Text2="Second Line, but its longer than sixty ""chars"", "
            Type=1
            ValNt=2091.75

          }
        }
      TAF
    end
  end

  describe '#tenant' do
    before { builder.tenant(tenant) }

    it 'builds correctly' do
      is_expected.to contain_exactly(be_a(Export::Taf::Block), be_a(Export::Taf::Block))
      expect(blocks.map(&:to_s).join("\n\n")).to eq(<<~TAF.chomp)
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
      TAF
    end
  end

  describe '#invoice_created_journal_entry' do
    let(:booking) do
      create(:booking, :invoiced, tenant:, organisation:, begins_at: '2024-12-20', ends_at: '2024-12-27',
                                  prepaid_amount: 300, vat_category:)
    end
    before { builder.invoice_created_journal_entry(booking.invoices.last.journal_entries.last) }

    it 'exports to taf' do
      expect(blocks.map(&:to_s).join("\n\n")).to eq(<<~TAF.chomp)
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

        }

        {Blg
          Date=27.12.2024
          Orig=1

          {Bk
            AccId=1050
            Date=27.12.2024
            Flags=1
            Text="R.250001 - Müller"
            Type=0
            ValNt=420.00
            PkKey=200002
            OpId=250001

          }

          {Bk
            AccId=6000
            Date=27.12.2024
            Text="R.250001 - Müller: Saldo"
            Type=1
            ValNt=-300.00
            CIdx=3

          }

          {Bk
            AccId=9001
            BType=1
            Date=27.12.2024
            Text="R.250001 - Müller: Saldo"
            Type=1
            ValNt=-300.00

          }

          {Bk
            AccId=6000
            Date=27.12.2024
            TaxId="VAT50"
            Text="R.250001 - Müller: Preis pro Übernachtung"
            Type=1
            ValNt=480.00
            CIdx=5
            TIdx=6

          }

          {Bk
            AccId=9001
            BType=1
            Date=27.12.2024
            Text="R.250001 - Müller: Preis pro Übernachtung"
            Type=1
            ValNt=480.00

          }

          {Bk
            AccId=2016
            BType=2
            Date=27.12.2024
            Text="R.250001 - Müller: Preis pro Übernachtung"
            Type=1
            ValNt=240.00
            ValTx=480.00

          }
        }
      TAF
    end
  end
end
