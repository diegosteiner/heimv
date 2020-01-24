module Invoices
  TYPES =
    {
      invoice: Invoices::Invoice,
      deposit: Invoices::Deposit,
      late_notice: Invoices::LateNotice
    }.freeze
end
