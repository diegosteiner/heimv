organisation = Organisation.create!(
  email: 'info@heimv.ch',
  name: 'Heimverein',
  address: 'Adresse',
  booking_strategy_type: BookingStrategies::Default.to_s,
  invoice_ref_strategy_type: RefStrategies::ESR.to_s,
  booking_ref_strategy_type: RefStrategies::DefaultBookingRef.to_s,
  esr_participant_nr: '',
  currency: 'CHF',
  message_footer: <<~MESSAGE_FOOTER
    HeimV

    [+41 79 000 00 00](tel:+41 79 000 00 00)
    [www.heimv.ch](//www.heimv.ch)
    [info@heimv.ch](mailto:info@heimv.ch)
  MESSAGE_FOOTER
)

User.create!(role: :admin, password: 'heimverwaltung', email: 'admin@heimv.local', organisation: organisation)
