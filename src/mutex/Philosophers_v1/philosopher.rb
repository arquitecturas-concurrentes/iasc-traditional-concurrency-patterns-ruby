require 'thread'

class Philosopher
  def initialize(name, left_fork, right_fork)
    @name = name
    @left_fork = left_fork
    @right_fork = right_fork
    while true
      think
      dine
    end
  end

  def think
    puts "#{@name} is thinking..."
    sleep(rand)
    puts "#{@name} is hungry..."
  end

  def dine
    while true
      @left_fork.lock
      puts "#{@name} has one fork..."
      if @right_fork.try_lock
        break
      else
        puts "#{@name} cannot pickup second fork"
        @left_fork.unlock
      end
    end
    puts "#{@name} has the second fork!"

    puts "#{@name} eats..."
    sleep(rand)
    puts "#{@name} belches"

    @left_fork.unlock
    @right_fork.unlock
  end
end

class DiningPhilosophers

  attr_accessor :n, :forks, :threads

  def initialize(number = 5)
    self.n = 5 #Number of philosophers
    self.forks = []
    self.threads = []

    self.initialize_mutexes
  end

  def run_processes
    (1..self.n).each do |i|
      self.threads << Thread.new do
        if i < n
          left_fork = self.forks[i]
          right_fork = self.forks[i+1]
        else
          # special case for philosopher #5 because he gets forks #5 and #1
          # and the left fork is always the lower id because that's the one we try first.
          left_fork = self.forks[0]
          right_fork = self.forks[n]
        end
        Philosopher.new(i, left_fork, right_fork)
      end
    end

    self.threads.each { |thread| thread.join }
  end

  def initialize_mutexes
    (1..self.n).each do
      self.forks << Mutex.new
    end
  end

end

dining = DiningPhilosophers.new
dining.run_processes