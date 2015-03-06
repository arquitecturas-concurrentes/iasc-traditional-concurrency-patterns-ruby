threads = []

Thread.abort_on_exception = false
#Thread continues on exception on one of them
5.times.each do |i|

  threads << Thread.new {
    raise Exception if i == 2
    puts "Thread #{i}: is executing\n"
  }

end

threads.each { |t| t.join }

