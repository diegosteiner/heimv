class RefService
  REFS = {
    Booking => (lambda do |booking|
                  format('%s%04d%02d-%s',
                         booking.home.ref,
                         booking.occupancy.begins_at.year,
                         booking.occupancy.begins_at.month,
                         booking.id.last(3)).upcase
                end),
    Invoice => (lambda do |invoice|
      ref = format('%03d%06d%012d', invoice.booking.home.id, invoice.booking.customer.id, invoice.id)
      ref + EsrService.new.checksum(ref).to_s
    end)
  }.freeze

  def call(subject)
    # REFS.find { |klass, ref| subject.is_a?(klass) }.&call(subject)
    REFS.each do |klass, block|
      # binding.pry
      return block.call(subject) if subject.is_a?(klass)
    end
    nil
  end
end
