require_relative 'semaphore'

class Program

  attr_accessor :bouncer

  def initialize
    self.bouncer = Semaphore.new(3)
    self.open_night_club
  end

  def open_night_club
    (1..50).step { |i|
       thread = Thread.new {
         Thread.current[:name] = i
         guest
       }
       sleep(0.5)
    }
  end

  def guest
    puts "Guest #{Thread.current[:name]} is waiting to entering nightclub."
    self.bouncer.synchronize {
      puts "Guest #{Thread.current[:name]} is doing some dancing."
      sleep(1.0)
      puts "Guest #{Thread.current[:name]} is leaving the nightclub."
    }
  end

end

Program.new