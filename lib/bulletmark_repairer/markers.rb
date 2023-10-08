# frozen_string_literal: true

require 'forwardable'

module BulletmarkRepairer
  class Markers
    extend Forwardable

    def_delegator :@markers, :each

    def initialize(notifications, controller:, action:)
      @markers = {}
      notifications.collection.to_a.each do |notification|
        next unless notification.is_a?(::Bullet::Notification::NPlusOneQuery)

        base_class = notification.instance_variable_get(:@base_class)
        if @markers[base_class]
          @markers[base_class].add_association(notification)
        else
          @markers[base_class] = Marker.new(
            notification,
            controller:,
            action:
          )
        end
      end
    end
  end

  class Marker
    attr_reader :base_class, :associations, :action, :file_name, :instance_variable_name, :index

    def initialize(notification, controller:, action:)
      @base_class = notification.instance_variable_get(:@base_class)
      @stacktraces = notification.instance_variable_get(:@callers)
      @associations = notification.instance_variable_get(:@associations)
      @controller = controller
      @action = action
      set_up
    end

    def add_association(notification)
      @associations += notification.instance_variable_get(:@associations)
    end

    def n_plus_one_in_view?
      @n_plus_one_in_view
    end

    private

    def set_up
      @n_plus_one_in_view = @stacktraces.any? { |stacktrace| stacktrace.match?(%r{\A#{Rails.root}/app/views/[./\w]+:\d+:in `[\w]+'\z}) }

      if n_plus_one_in_view?
        # TODO: Check the action is in the base controller file
        @file_name = "#{Rails.root}/app/controllers/#{@controller}_controller.rb"
        view_file_index = @stacktraces.index do |stacktrace|
          stacktrace =~ %r{\A(#{Rails.root}/app/views/[./\w]+):\d+:in `[\w]+'\z} && !Pathname.new(Regexp.last_match(1)).basename.to_s.start_with?('_')
        end
        view_file, view_yield_index = @stacktraces[view_file_index].scan(%r{\A(/[./\w]+):(\d+):in `[\w]+'\z}).flatten
        view_yield_index = view_yield_index.to_i
        # TODO: Compile views
        File.open(view_file) do |f|
          lines = f.readlines
          loop do
            break if @instance_variable_name || view_yield_index.zero?

            view_yield_index -= 1
            line = lines[view_yield_index]
            @instance_variable_name = line&.scan(/\b?(@[\w]+)\b?/)&.flatten&.last
          end
        end
        @index = view_yield_index.negative? ? ':' : "#{view_file}:#{view_yield_index}"
      else
        # TODO: Ignore controllers list
        other_file_index = @stacktraces.index { |stacktrace| stacktrace.match?(%r{\A(#{Rails.root}[./\w]+):(\d+):in `[()\w\s]+'\z}) }
        @file_name, other_yield_index = @stacktraces[other_file_index].scan(%r{\A(#{Rails.root}[./\w]+):(\d+):in `[()\w\s]+'\z}).flatten
        other_yield_index = other_yield_index.to_i
        File.open(@file_name) do |f|
          lines = f.readlines
          loop do
            break if @instance_variable_name || other_yield_index.zero?

            other_yield_index -= 1
            line = lines[other_yield_index]
            # TODO: patch to local variables
            @instance_variable_name = line&.scan(/\b?(@[\w]+)\b?/)&.flatten&.last
            break if line.match?(/^\s+def [()\w\s=]+$/)
          end
        end
        @index = @instance_variable_name ? "#{@file_name}:#{other_yield_index}" : ':'
      end
    end
  end
end
