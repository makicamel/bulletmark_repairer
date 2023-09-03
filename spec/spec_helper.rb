# frozen_string_literal: true

require 'action_controller/railtie'
require 'active_record/railtie'

require 'bulletmark_repairer'

module BulletmarkRepairerTestApp
  class Application < Rails::Application
    config.eager_load = false
    config.active_support.deprecation = :log
    config.root = "#{__dir__}/fake_app"
    config.secret_key_base = 'bulletmark repairer'
  end
end

BulletmarkRepairerTestApp::Application.initialize!
ActiveRecord::Tasks::DatabaseTasks.drop_current 'test'
ActiveRecord::Tasks::DatabaseTasks.create_current 'test'

require_relative 'fake_app/fake_app'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
