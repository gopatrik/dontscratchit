require 'socket' # Sockets are in standard library
require 'net/telnet'
require 'json'
require_relative 'lib'

hostname = '192.168.1.10'
port = Util.port

# "%X telnet 192.168.1.9 2000

server = TCPSocket.open hostname, port


loop do
	server_time = server.gets.to_i
	puts Time.now.to_ms - server_time
end
puts server.gets.chomp

