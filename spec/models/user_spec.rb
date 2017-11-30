# frozen_string_literal: true

describe User do
  before(:each) { @user = User.new(email: 'user@example.com') }

  it do
    DatabaseCleaner.cleaning do
      FactoryBot.lint
    end
  end

  subject { @user }

  it { should respond_to(:email) }

  it '#email returns a string' do
    expect(@user.email).to match 'user@example.com'
  end
end
