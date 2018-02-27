class TestTupel
  attr_accessor :tupels, :struct

  def initialize(*args)
    @tupels = []
    @struct = Struct.new(*args)
    yield tupels, struct
  end

  delegate :each, :map, to: :tupels
end
