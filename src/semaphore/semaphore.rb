require 'monitor'

class Semaphore

  attr_accessor :mon, :max, :count, :dwait, :uwait

  def initialize(maxval = nil)
    maxval = maxval.to_i unless maxval.nil?
    raise SemaphoreException.new('Semaphores must use a positive maximum value') if maxval and maxval <= 0
    self.max = maxval || -1
    self.count = 0
    self.mon = Monitor.new
    self.dwait = self.mon.new_cond
    self.uwait = self.mon.new_cond
  end

  def count_sync
    self.mon.synchronize { self.count }
  end

  def increment(number = 1)
    if number > 1
      number.times { increment 1 }
      self.count_sync
    else
      self.mon.synchronize do
        self.uwait.wait while self.max > 0 and self.count == self.max
        self.dwait.signal if self.count == 0
        self.count += 1
      end
    end
  end

  def decrement(number = 1)
    if number > 1
      number.times { decrement 1 }
      self.count_sync
    else
      self.mon.synchronize do
        self.dwait.wait while self.count == 0
        self.uwait.signal if self.count == self.max
        self.count -= 1
      end
    end
  end

  def synchronize
    increment
    yield
  ensure
    decrement
  end

end

class SemaphoreException < StandardError
end