require 'resolv'
require 'net/http'

class FRPThread < Thread
end

pages = %w( www.rubycentral.org
            www.awl.com
            www.pragmaticprogrammer.com
           )

threads = []

pages.each do |page|
  threads << FRPThread.new(page) { |myPage|
    h = Net::HTTP.new(myPage, 80)
    puts "Fetching: #{myPage}"
    resp, data = h.get('/', nil)
    puts "Got #{myPage}:  #{resp.message}"
  }
end

threads.each { |aThread| aThread.join }
