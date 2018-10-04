class EsrService
  def checksum(number)
    check_table = [0, 9, 4, 6, 8, 2, 7, 1, 3, 5]
    10 - number.to_s.scan(/\d/).inject(0) { |carry, digit| check_table[(digit.to_i + carry) % check_table.size] }
  end
end
