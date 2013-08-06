require 'socket' # Sockets are in standard library
# require 'json'

hostname = '192.168.1.9'
port = 2000

def start_chat name, socket
	puts "Connected!"

	Thread.start(socket) do
		loop { puts socket.gets.chomp } # Get data from server
	end
	
	loop { socket.puts "#{name}: #{gets}" } # Send data to server
end

def init
	puts 'Connecting...'
	socket = TCPSocket.open(hostname, port) # init socket
	start_chat('Patrik', socket)
end

init

socket.close # Close the socket when done

