class Address
  attr_reader :zipcode, :place, :street_address, :name, :organisation

  def initialize(zipcode:, place:, street_address:, name:, organisation:, country_code:)
    @zipcode = zipcode
    @place = place
    @street_address = street_address
    @name = name
    @organisation = organisation
    @country_code = country_code
  end
end
