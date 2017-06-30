class PeopleController < ApplicationController
  before_action :set_person, only: %i[show edit update destroy]
  before_action :authenticate_user!

  def index
    @people = Person.all
  end

  def show
    breadcrumbs.add @person.to_s
  end

  def new
    breadcrumbs.add t('new')
    @person = Person.new
  end

  def edit
    breadcrumbs.add @person.to_s, person_path(@person)
    breadcrumbs.add t('edit')
  end

  def create
    @person = Person.new(person_params)

    if @person.save
      redirect_to @person, notice: 'Person was successfully created.'
    else
      render :new
    end
  end

  def update
    if @person.update(person_params)
      redirect_to @person, notice: 'Person was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @person.destroy
    redirect_to people_url, notice: 'Person was successfully destroyed.'
  end

  private

  def set_breadcrumbs
    super
    breadcrumbs.add(Person.model_name.human(count: 2), people_path)
  end

  def set_person
    @person = Person.find(params[:id])
  end

  def person_params
    params.require(:person).permit(:firstname, :lastname, :street_address, :zipcode, :city)
  end
end
