module PersonHelper
  def people_for_select
    Person.all.map { |person| ["#{person.name}, #{person.zipcode} #{person.city}", person.to_param] }
  end
end
