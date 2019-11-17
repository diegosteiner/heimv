require 'csv'

class DataDigest < ApplicationRecord
  belongs_to :organisation

  validates :label, presence: true

  def self.default_csv_options
    {
      col_sep: ';',
      write_headers: true,
      skip_blanks: true,
      force_quotes: true,
      encoding: 'utf-8'
    }
  end

  def self.default_pdf_options
    {
      document_options: { page_layout: :landscape }
    }
  end

  def formats
    %i[csv]
  end

  def records
    []
  end

  def to_pdf(options = {})
    options = self.class.default_pdf_options.merge(options)
    Export::Pdf::DataDigest.new(self, organisation, options).build.render
  end

  def to_tabular
    data = []
    data << generate_tabular_header
    data += records.map { |record| generate_tabular_row(record) }
    data << generate_tabular_footer
  end

  def to_csv(options = {})
    options = self.class.default_csv_options.merge(options)
    CSV.generate(options) { |csv| to_tabular.each { |row| csv << row } }
  end

  def column_widths
    []
  end

  protected

  def generate_tabular_header; end

  def generate_tabular_footer; end

  def generate_tabular_row(booking); end
end
