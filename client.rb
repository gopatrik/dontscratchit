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
		# the_loop
		Thread.start(the_loop)
	end
	
	def the_loop
		# loop do
		# 	server_time = @server.gets.to_i
		# 	p server_time
		# 	@diff_list << Time.now.to_ms - server_time
		# 	puts "::#{@diff_list.average.to_i}"
		# end

		loop do input = @server.gets.chomp
			p input
			if input.start_with? 'TIME'
				self.send_diff(input[5..-1].to_i)
			else
				puts "JSON: " + input
			end
		end
	end

	def send_diff server_time
		@diff_list << Time.now.to_ms - server_time 

		if(@diff_list.size % 10 == 0) then
			@server.print "TIME:#{@diff_list.average.to_i}"
			@diff_list.clear

		elsif @diff_list.size == 1
			@server.print "TIME:#{@diff_list.average.to_i}"
		end
	end
	
end

cl = Client.new

# cl.the_loop


