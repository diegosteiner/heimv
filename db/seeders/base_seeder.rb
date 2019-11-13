require 'factory_bot_rails'
require 'faker'

Faker::Config.locale = :de

module Seeders
  class BaseSeeder
    include FactoryBot::Syntax::Methods
    attr_accessor :options

    def initialize(options = {})
      @options = options
    end

    def seed(seeded = {}, env = Rails.env)
      seeds = self.class.seeds_for_env[env.to_s]
      seeds.present? && instance_exec(seeded, &seeds) || {}
    end

    class << self
      def seeds_for_env
        @seeds_for_env ||= {}
      end

      def seed(envs, &block)
        seeds_for_env
        Array.wrap(envs).each { |env| @seeds_for_env[env.to_s] = block }
      end
    end
  end
end
