organisation = Organisation.create(
  name: 'Heimverein',
  address: '',
  booking_strategy_type: BookingStrategies::Default.to_s,
  invoice_ref_strategy_type: RefStrategies::ESR.to_s,
  booking_ref_strategy_type: RefStrategies::DefaultBookingRef.to_s,
  esr_participant_nr: '',
  currency: 'CHF',
  message_footer: <<~MESSAGE_FOOTER
    Verein Pfadiheime St. Georg
    Heimverwaltung

    Christian Morger
    Geeringstrasse 44
    8049 Zürich
    Switzerland

    [+41 79 262 25 48](tel:+41 79 262 25 48)
    [www.pfadi-heime.ch](//www.pfadi-heime.ch)
    [info@pfadi-heime.ch](mailto:info@pfadi-heime.ch)
  MESSAGE_FOOTER
)

User.create!(role: :admin, password: 'heimverwaltung', email: 'admin@heimv.localhost', organisation: organisation)
