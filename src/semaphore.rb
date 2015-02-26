require 'monitor'

class Semaphore

  attr_accessor :monitor, :max, :count, :down_wait, :signal_wait, :count

  def initialize(maximum_value = nil)
    maximum_value = maximum_value.to_i unless maximum_value.nil?
    raise ArgumentError.new('Semaphores must use a positive maximum value') if maximum_value and maximum_value <= 0
    self.max   = maximum_value || -1
    self.count = 0
    self.monitor   = Monitor.new
    self.down_wait = self.monitor.new_cond
    self.signal_wait = self.monitor.new_cond
  end

  def count_sync
    self.monitor.synchronize { self.count } end

  def signal(number = 1)
    if number > 1
      number.times { signal(1) }
      count_sync
    else
      self.monitor.synchronize do
        self.signal_wait.wait while self.max > 0 and self.count == self.max
        self.down_wait.signal if self.count == 0
        self.count += 1
      end
    end
  end

  def wait(number = 1)
    if number > 1
      number.times { wait(1) }
      count_sync
    else
      self.monitor.synchronize do
        self.down_wait.wait while self.count == 0
        self.signal_wait.signal if self.count == self.max
        self.count -= 1
      end
    end
  end
end