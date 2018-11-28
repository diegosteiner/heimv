class RefService
  REFS = {
    Booking => (lambda do |booking|
                  format('%s%04d%02d-%d',
                         booking.home.ref[0...1],
                         booking.occupancy.begins_at.year,
                         booking.occupancy.begins_at.month,
                         booking.occupancy.begins_at.day).upcase
                end),
    Invoice => (lambda do |invoice|
      ref = format('%03d%06d%012d', invoice.booking.home.id, invoice.booking.tenant.id, invoice.id)
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
