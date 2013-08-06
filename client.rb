require 'socket' # Sockets are in standard library
require 'net/telnet'
require 'json'
require_relative 'lib'

class Client
	HOSTNAME = '192.168.1.9'
	PORT = Util.port
	def initialize
		@server = TCPSocket.open HOSTNAME, PORT
		@diff_list = Array.new
		the_loop
	end
	
	def the_loop
		loop do
			server_time = @server.gets.to_i
			p server_time
			@diff_list << Time.now.to_ms - server_time
			puts "::#{@diff_list.average.to_i}"
		end
	end
	
end

Client.new
