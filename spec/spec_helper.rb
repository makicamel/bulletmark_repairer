# frozen_string_literal: true

require 'byebug'

require 'action_controller/railtie'
require 'active_record/railtie'
require 'bullet'

require 'bulletmark_repairer'

module BulletmarkRepairerTestApp
  class Application < Rails::Application
    config.eager_load = false
    config.active_support.deprecation = :log
    config.root = "#{__dir__}/fake_app"
    config.secret_key_base = 'bulletmark repairer'
    config.hosts = ['localhost']
    config.after_initialize do
      ::Bullet.enable = true
      ::Bullet.bullet_logger = true
    end
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
  config.before(:all, type: :request) do
    host! 'localhost'
  end
end

RSpec.shared_examples 'correctly patched' do
  it do
    File.open(filename) do |f|
      src = f.read
      expect(src.include?(original_src)).to eq true
      expect(src.include?(patched_src)).to eq false
    end

    subject

    File.open(filename) do |f|
      src = f.read
      expect(src.include?(original_src)).to eq false
      expect(src.include?(patched_src)).to eq true
    end

    system("git checkout #{filename}")
  end
end
