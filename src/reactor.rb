require 'thread'


module Reactor

  class Event
    attr_accessor :io, :callbacks, :status, :valid_statuses

    def initialize(io, &callback)
      self.io = io
      self.callbacks = [callback] if callback
      self.status = :clean
      self.valid_statuses = [:clean, :dirty]
    end

    def get_callback
      self.callbacks[0]
    end

    def callbacks
      @callbacks ||= []
    end

    def is_dirty?
      self.status == :dirty
    end

    def change_status(status)
      unless self.valid_statuses.include? status
        raise ReactorException, 'Invalid status'
      end
      self.status = status
    end

    def add_callback(wait_if_attached, &callback)
      unless wait_if_attached
        self.callbacks = [callback]
        self.change_status :dirty
        return
      end
      self.callbacks << callback
    end

    def has_callbacks?
      self.callbacks.length > 0
    end

    def remove_last_callback
      self.callbacks.delete self.callbacks[-1]
    end

  end

  class EventHandlerManager

    attr_accessor :mode, :events

    def initialize(mode)
      self.mode = mode
      self.events = []
    end

    def is_io_included(io)
      self.events.each do |event|
        if event.io == io
          return event
        end
      end
      nil
    end

    def remove_all_events
      self.events = []
    end

    def attach(io, wait_if_attached=True, &callback)
      event = self.is_io_included io
      unless event.nil?
        #Add the callback to an existing event
        event.add_callback wait_if_attached, &callback
        return
      end
      self.events << (Event.new io, &callback)
    end

    def detach(event, force)
      if !force && event.has_callbacks?
        event.remove_last_callback
        return
      end

      self.events.delete(event)
      self.change_status :dirty

    end

    def get_events_io
      dirty_events = []
      events = []
      self.events.each do |event|
        if event.is_dirty?
          dirty_events << event.io
        else
          events << event.io
        end
      end
      return events, dirty_events
    end


    def get_event(io)
      self.is_io_included io
    end

  end

  class Dispatcher

    attr_accessor :running, :handler_manager_read, :handler_manager_write, :on_attach, :on_detach, :ios

    def initialize
      self.handler_manager_read = EventHandlerManager.new :read
      self.handler_manager_write = EventHandlerManager.new :write
      self.running = true
      self.ios= []
    end


    def is_running?
      running
    end

    def run
      yield self if block_given?
      while is_running?
        run_cycle
      end
    end

    def run_cycle
      read_ios, dirty_read_ios = get_events_for :read
      write_ios, dirty_write_ios = get_events_for :write
      event = IO.select(read_ios, write_ios, nil, 0.005)
      if event
        fire_events :read, event[0]
        fire_events :write, event[1]
      end
    end


    def attach_handler(mode, io, wait_if_attached = true, &callback)
      if callback.nil?
        raise ReactorException, 'A callback block should be passed to the attach_handler.'
      end

      handler_manager = get_handler_manager mode
      handler_manager.attach io, wait_if_attached, &callback

      self.on_attach.call(mode, io) if self.on_attach
    end

    def detach_handler(mode, io, force=False)
      handler_manager = get_handler_manager mode
      handler = handler_manager.is_io_included
      unless handler io
        #The io doesn't exits anymore
        return
      end

      handler_manager.detach handler, force
      self.on_detach.call(mode, io) if self.on_detach

    end

    def detach_all_handlers(mode)
      handler_manager = get_handler_manager mode
      handler_manager.remove_all_events
    end

    def get_handler_manager(mode)
      check_valid_mode mode
      self.instance_variable_get("@handler_manager_#{mode}")
    end

    def get_events_for(mode)
      handler_manager = get_handler_manager mode
      handler_manager.get_events_io
    end

    def fire_events mode, ios
      handler_manager = get_handler_manager mode
      ios.each do |io|
        event = handler_manager.get_event io
        self.ios << [io, event.get_callback]
      end
      self.process_ios
    end

    def process_ios
      ios.each{|io| self.process_io io}.clear
    end

    def process_io(io)
      io[1].call io[0],self
    end

    def check_valid_mode(mode)
      unless [:read, :write].include? mode
        raise ReactorException, "Mode #{mode} is not a valid one."
      end
    end

  end


end


class ReactorException < StandardError
end
