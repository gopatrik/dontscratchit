require 'socket' # Sockets are in standard library
require 'net/telnet'
require 'json'
require_relative 'lib'

hostname = '192.168.1.10'
port = Util.port

# "%X telnet 192.168.1.9 2000

server = TCPSocket.open hostname, port

array = Array.new

loop do
	server_time = server.gets.to_i
	array << Time.now.to_ms - server_time
	puts "::#{(array.reduce(:+).to_f / array.size).to_i}"
end
puts server.gets.chomp

