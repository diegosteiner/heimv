require 'factory_bot_rails'
require 'faker'

Faker::Config.locale = 'de-CH'

module Seeders
  class BaseSeeder
    include FactoryBot::Syntax::Methods
    attr_accessor :options

    def initialize(options = {})
      @options = options
    end

  class << self
    attr_reader :seeds_for_env

    def seed(env, &block)
      @seeds_for_env ||= {}
      @seeds_for_env[env.to_s] = block
    end
  end

    def seed(seeded = {}, env = Rails.env)
      seeds = self.class.seeds_for_env[env.to_s]
      instance_exec(seeded, &seeds) if seeds.present?
    end
  end
end
