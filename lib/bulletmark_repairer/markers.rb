# frozen_string_literal: true

require 'forwardable'

module BulletmarkRepairer
  class Markers
    extend Forwardable

    def_delegator :@markers, :each_value

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
            controller: controller,
            action: action
          )
        end
      end
    end
  end

  class Marker
    attr_reader :base_class, :associations, :action, :file_name, :instance_variable_name, :index, :retry, :line_no

    def initialize(notification, controller:, action:)
      @base_class = notification.instance_variable_get(:@base_class)
      @stacktraces = notification.instance_variable_get(:@callers)
      @associations = notification.instance_variable_get(:@associations)
      @controller = controller
      @action = action
      @retry = false
      @line_no = nil
      set_up
    end

    def add_association(notification)
      @associations += notification.instance_variable_get(:@associations)
    end

    def skip?
      log_patchable_files_not_be_found
      index.nil? || file_name.remove("#{Rails.root}/").in?(BulletmarkRepairer.config.skip_file_list)
    end

    def n_plus_one_in_view?
      @n_plus_one_in_view
    end

    private

    def log_patchable_files_not_be_found
      return if index
      return if BulletmarkRepairer.config.skip_file_list.exclude?(file_name.remove("#{Rails.root}/"))

      BulletmarkRepairer.config.logger.info <<~LOG
        Repairer couldn't patch
        #{"#{@controller}_controller".camelize.constantize}##{@action}
        #{base_class} => #{associations}
        Might be able to add one of the following
          includes(#{associations}) / includes(#{base_class.underscore}: #{associations}) / includes(#{base_class.underscore.pluralize}: #{associations})
        Stacktraces
          #{@stacktraces.join("\n  ")}
      LOG
    end

    def set_up
      @n_plus_one_in_view = @stacktraces.any? { |stacktrace| stacktrace.match?(%r{\A#{Rails.root}/app/views/[./\w]+:\d+:in [`'][#:\w]+'\z}) }

      if n_plus_one_in_view?
        # TODO: Check the action is in the base controller file
        @file_name = "#{Rails.root}/app/controllers/#{@controller}_controller.rb"
        view_file_index = @stacktraces.index do |stacktrace|
          stacktrace =~ %r{\A(#{Rails.root}/app/views/[./\w]+):\d+:in [`'][#:\w]+'\z} && !Pathname.new(Regexp.last_match(1)).basename.to_s.start_with?('_')
        end
        view_file, view_yield_index = @stacktraces[view_file_index].scan(%r{\A(/[./\w]+):(\d+):in [`'][#:\w]+'\z}).flatten
        view_yield_index = view_yield_index.to_i
        File.open(view_file) do |f|
          lines = f.readlines
          loop do
            break if @instance_variable_name || view_yield_index.zero?

            view_yield_index -= 1
            line = lines[view_yield_index]
            scanned = line&.scan(/\b?(@\w+)\b?/)
            token = scanned&.flatten&.last
            @instance_variable_name = token if BulletmarkRepairer::Thread.instance_variable_name?(token)
          end
        end
        @index = @instance_variable_name ? "#{view_file}:#{view_yield_index}" : nil
      else
        # TODO: Ignore controllers list
        controller_file_index = @stacktraces.index { |stacktrace| stacktrace.match?(%r{\A(#{Rails.root}/app/controllers[./\w]+):(\d+):in [`'][#:()\w\s]+'\z}) }
        @file_name, controller_yield_index = @stacktraces[controller_file_index].scan(%r{\A(#{Rails.root}/app/controllers[./\w]+):(\d+):in [`'][#:()\w\s]+'\z}).flatten
        controller_yield_index = controller_yield_index.to_i
        File.open(@file_name) do |f|
          lines = f.readlines
          loop do
            break if @instance_variable_name || controller_yield_index.zero?

            controller_yield_index -= 1
            line = lines[controller_yield_index]
            scanned = line&.scan(/\b?(@\w+)\b?/)
            @instance_variable_name = scanned&.flatten&.last
            break if line.match?(/^\s+def [()\w\s=]+$/)
          end
        end
        @index = @instance_variable_name ? "#{@file_name}:#{controller_yield_index}" : nil
      end

      return if @index

      # TODO: Ignore files list
      # TODO: Allow model files list
      @retry = @stacktraces.any? do |stacktrace|
                 !stacktrace.match?(%r{\A(#{Rails.root}/app/models[./\w]+):(\d+):in [`'][#:()\w\s=!?]+'\z}) &&
                   stacktrace =~ %r{\A(#{Rails.root}/app[./\w]+):(\d+):in [`'][#:()\w\s=!?]+'\z}
               end.tap do
        @file_name = Regexp.last_match(1)
        @line_no = Regexp.last_match(2)
      end
      @index = @retry ? "#{@file_name}:#{@line_no}" : nil
    end
  end
end
