require 'socket' # Sockets are in standard library
require 'net/telnet'
require 'json'
require_relative 'lib'

class Client
	HOSTNAME = '127.0.0.1'
	PORT = Util.port
	def initialize
		@server = TCPSocket.open HOSTNAME, PORT
		@diff_list = Array.new
		Thread.start { get_loop }
		input_loop
		
	end
	
	def get_loop
		loop do input = @server.gets.chomp
			if input.start_with? 'TIME'
				self.send_diff(Util.remove_prefix input)
			elsif input.start_with? 'DIFF'
				puts input
			else # JSON
				puts input
			end
		end

	end

	def input_loop
		loop do
			@server.print gets.chomp
		end
	end

	def send_diff server_time
		# puts server_time
		@diff_list << Time.now.to_ms - server_time 
		if(@diff_list.size % 10 == 1) then
			@server.print "TIME:#{@diff_list.average.to_i}"
			@diff_list.clear
		end
	end
	
end

cl = Client.new

