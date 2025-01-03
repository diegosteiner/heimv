# frozen_string_literal: true

require 'rails_helper'

describe Export::Taf::Builder, type: :model do
  let(:organisation) { create(:organisation, accounting_settings:) }
  let(:accounting_settings) { { enabled: true } }
  let(:booking) { create(:booking, organisation:, tenant:) }
  let(:vat_category) { create(:vat_category, percentage: 3.8, accounting_vat_code: 'MwSt38', organisation:) }
  let(:tenant) do
    create(:tenant, sequence_number: 200_002, first_name: 'Max', last_name: 'Müller', organisation:,
                    street_address: 'Bahnhofstr. 1', city: 'Bern', zipcode: 1234)
  end

  subject(:builder) { described_class.new }

  describe 'build_with_journal_entry' do
    subject(:taf_block) { builder.build_with_journal_entry(journal_entry) }
    let(:journal_entry) do
      JournalEntry.new(account_nr: 1050, amount: 2091.75, date: Date.new(2024, 10, 5), ref: '1234',
                       side: :soll, vat_category:, booking:,
                       text: "Lorem ipsum\nSecond Line, but its longer than sixty \"chars\", OMG!")
    end

    it 'builds correctly' do
      is_expected.to be_a(Export::Taf::Block)
      expect(taf_block.to_s).to eq(<<~TAF.chomp)
        {Bk
          AccId=1050
          Date=05.10.2024
          TaxId="MwSt38"
          Text="Lorem ipsum"
          Text2="Second Line, but its longer than sixty ""chars"", "
          Type=0
          ValNt=2091.75

        }
      TAF
    end
  end

  describe 'build_with_tenant' do
    subject(:taf_blocks) { builder.build_with_tenant(tenant) }

    it 'builds correctly' do
      is_expected.to contain_exactly(be_a(Export::Taf::Block), be_a(Export::Taf::Block))
      expect(taf_blocks.map(&:to_s).join("\n\n")).to eq(<<~TAF.chomp)
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
          ZabId="15T"

        }
      TAF
    end
  end

  describe 'build_with_invoice_created_journal_entry_compounds' do
    subject(:taf_document) do
      journal_entry_compounds = compounds
      Export::Taf::Document.new do
        journal_entry_compounds.each { build_with_journal_entry_compound(_1) }
      end
    end
    subject(:compounds) { JournalEntry::Compound.group(invoice.journal_entries) }

    let(:accounting_settings) do
      { enabled: true, debitor_account_nr: 1050, vat_account_nr: 6020,
        payment_account_nr: 4000, rental_yield_account_nr: 6000 }
    end
    let(:vat_category) { create(:vat_category, percentage: 50, organisation:) }
    let(:payment) { create(:payment, booking:, invoice: nil, amount: 300) }
    let(:usages) { Usage::Factory.new(booking).build.each { _1.update(used_units: 48) } }
    let(:invoice) do
      tarif
      usages
      payment
      build(:invoice, booking:, invoice_parts: []).tap do |invoice|
        invoice.invoice_parts = InvoicePart::Factory.new(invoice).call
        invoice.save!
        invoice.recalculate!
      end
    end
    let(:tarif) do
      create(:tarif, organisation:, vat_category:, price_per_unit: 15,
                     accounting_account_nr: 6000, accounting_cost_center_nr: 9000)
    end

    it 'creates to correct journal_entries' do
      expect(compounds).to contain_exactly(
        contain_exactly(
          have_attributes(account_nr: '4000', soll_amount: 300.0, trigger: 'payment_created'),
          have_attributes(account_nr: '1050', haben_amount: 300.0, trigger: 'payment_created')
        ),
        contain_exactly(
          have_attributes(account_nr: '1050', soll_amount: 420.0, trigger: 'invoice_created'),
          have_attributes(account_nr: '6000', haben_amount: -300.0, trigger: 'invoice_created'),
          have_attributes(account_nr: '6000', haben_amount: 480.0, trigger: 'invoice_created'),
          have_attributes(account_nr: '9000', haben_amount: 480.0, trigger: 'invoice_created'),
          have_attributes(account_nr: '6020', haben_amount: 240.0, trigger: 'invoice_created')
        )
      )
    end

    it 'exports to taf' do
      expect(taf_document.to_s).to eq(<<~TAF.chomp)
        {Blg
          Date=11.10.2018

          {Bk
            AccId=4000
            Code=27
            Date=11.10.2018
            Text="Zahlung 250001"
            Type=0
            ValNt=300.00

          }

          {Bk
            AccId=1050
            Code=28
            Date=11.10.2018
            Text="Zahlung 250001"
            Type=1
            ValNt=300.00

          }
        }

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
            Code=34
            Date=27.12.2024
            Flags=1
            Text="250001 - Müller"
            Type=0
            ValNt=420.00
            PkKey=200002
            OpId=250001
            CAcc=div

          }

          {Bk
            AccId=6000
            Code=35
            Date=27.12.2024
            Text="250001 Saldo"
            Type=1
            ValNt=-300.00
            CAcc=1050

          }

          {Bk
            AccId=6000
            Code=36
            Date=27.12.2024
            Text="250001 Preis pro Übernachtung"
            Type=1
            ValNt=480.00
            CIdx=5
            TIdx=6
            CAcc=1050

          }

          {Bk
            AccId=9000
            BType=1
            Code=37
            Date=27.12.2024
            Text="250001 Preis pro Übernachtung"
            Type=1
            ValNt=480.00
            CAcc=1050

          }

          {Bk
            AccId=6020
            BType=2
            Code=38
            Date=27.12.2024
            Text="250001 Preis pro Übernachtung"
            Type=1
            ValNt=240.00
            ValTx=480.00
            CAcc=1050

          }
        }
      TAF
    end
  end
end
