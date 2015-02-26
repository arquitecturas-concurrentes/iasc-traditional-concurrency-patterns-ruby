require 'monitor'

class Semaphore
  def initialize(maxval = nil)
    maxval = maxval.to_i unless maxval.nil?
    raise ArgumentError.new('Semaphores must use a positive maximum value') if maxval and maxval <= 0
    @max   = maxval || -1
    @count = 0
    @mon   = Monitor.new
    @dwait = @mon.new_cond
    @uwait = @mon.new_cond
  end

  def count_sync
    @mon.synchronize { @count } end

  def increment(number = 1)
    if number > 1
      number.times { increment 1 }
      count_sync
    else
      @mon.synchronize do
        @uwait.wait while @max > 0 and @count == @max
        @dwait.signal if @count == 0
        @count += 1
      end
    end
  end

  def decrement(number = 1)
    if number > 1
      number.times { decrement 1 }
      count_sync
    else
      @mon.synchronize do
        @dwait.wait while @count == 0
        @uwait.signal if @count == @max
        @count -= 1
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