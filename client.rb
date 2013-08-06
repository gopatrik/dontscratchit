require 'socket' # Sockets are in standard library
require 'net/telnet'
require 'json'

hostname = '192.168.1.9'
port = 2000

# "%X telnet 192.168.1.9 2000

server = TCPSocket.open hostname, port


loop do
	server_time = server.gets.chomp.to_i
	puts Time.now.to_i - server_time
end
puts server.gets.chomp

