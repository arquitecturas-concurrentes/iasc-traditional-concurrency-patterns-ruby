class Table
  def initialize(hash)
    @hash = hash
    @mutex = Mutex.new
  end

  def put(key, value)
    @mutex.synchronize do
      @hash[key] = value
    end
  end

  def get(key)
    @mutex.synchronize do
      @hash[key]
    end
  end

  def delete(key)
    @mutex.synchronize do
      @hash.delete key
    end
  end

  def accum(key, delta)
    @mutex.synchronize do
      @hash[key] += delta
    end
  end
end


def concurrent_test(count)
  table = Table.new({counter: 0})
  (1..count).map do |it|
    if it.even?
      Thread.new do
        table.put(:counter, 1)
      end
    else
      Thread.new do
        v = table.get(:counter)
        table.put(:counter, 2)
      end
    end
  end.each(&:join)
  table
end



def concurrent_test2(count)
  table = Table.new({counter: 0})
  (1..count).map do |it|
    if it.even?
      Thread.new do
        table.accum(:counter, 1)
      end
    else
      Thread.new do
        table.accum(:counter, -1)
      end
    end
  end.each(&:join)
  table
end