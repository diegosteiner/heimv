require 'factory_bot_rails'
require 'faker'

Faker::Config.locale = 'de-CH'

module Seeders
  class BaseSeeder
    include FactoryBot::Syntax::Methods
    attr_accessor :options
    @seeds_for_env = {}

    def initialize(options = {})
      @options = options
    end

    def seed(seeded = {}, env = Rails.env)
      seeds = self.class.seeds_for_env[env.to_s]
      seeds.present? && instance_exec(seeded, &seeds) || {}
    end

    class << self
      attr_reader :seeds_for_env

      def seed(envs, &block)
        Array.wrap(envs).each { |env| @seeds_for_env[env.to_s] = block
      end
    end
  end
end
