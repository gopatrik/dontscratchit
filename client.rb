require 'socket' # Sockets are in standard library
require 'json'

hostname = '192.168.1.9'
port = 2000

def start_chat name, scoket
	puts "scoket connected"
	Thread.start(scoket) do 
		puts " -- Recieve loop started -- "
		loop do
			puts scoket.gets.chomp
		end
		puts " -- Recieve loop ended -- "
	end
	puts " -- Send loop started -- "
	loop do
		scoket.puts "#{name}: #{gets}"
	end
	puts " -- Send loop ended --"
end


puts 'Connecting...'
scoket = TCPSocket.open(hostname, port) # init socket

name = 'Patrik'

start_chat name, scoket

puts 'Connected!'

scoket.close # Close the socket when done

