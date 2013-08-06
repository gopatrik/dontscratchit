require 'eventmachine'
require 'json'
require_relative 'lib'

class Board

	def initialize()
		@board = Array.new 64, false
	end

	# array of strings ['-0', '14' .....]
	def parse_diff(arr)
		arr = Array.new(1, arr) if arr.is_a?(String)

		arr.each do |e|  
			set_square_state(e.to_i, /^-/.match(e).nil?)  
		end
	end

	def set_square_state(id, value)
		@board[id.abs] = value
	end

	def draw
		cols = Math.sqrt @board.size
		@board.each_with_index do |square, i|
			puts "" if (i % cols == 0 && i != 0)

			print "[#{square ? 'X' : ' '}]\t"
		end
		3.times do puts end
	end
	
	
end


class SimpleChatServer < EM::Connection

	@@connected_clients = Hash.new
	@started = false

	@@board = Board.new
	
	#
	# EventMachine handlers
	#

	def the_loop
		@started = true
		 Thread.start() do
			until @@connected_clients.empty? do
				sleep(1)
				self.announce("TIME:#{Time.now.to_ms.to_s}", true)
			end
			@started = false
		 end
	end

	def post_init
		@@connected_clients[self] = {
			:offset => 0
		}
		self.the_loop unless @started
		puts "A client has connected..."
	end

	def unbind
		@@connected_clients.delete(self)
		puts "A client has left..."
	end

	def next_beat_time
		10 #current_beat
	end

	def next_beat client
		"DIFF:#{next_beat_time + @@connected_clients[client][:offset]}"
	end

	def receive_data(data)
		if data.start_with? "TIME" then
			@@connected_clients[self][:offset] = Util.remove_prefix data
			self.send_line "#{self}: #{next_beat(self)}"
		else
			begin
				data = JSON.parse(data.strip)
				self.announce data

				@@board.parse_diff data["diff"]
				puts "#{data['name']} changed the board!" unless data["name"].nil?
				@@board.draw
			rescue Exception => e
				p e
				self.send_line e
			end
		end
	end

	#
	# Helpers
	#

	def announce(msg = nil, all = false)
		if all
			@@connected_clients.each { |c, v| c.send_line("#{msg}") } unless msg.empty?
		else
			self.other_peers.each { |c, v| c.send_line("#{msg}") } unless msg.empty?
		end
	end

	def other_peers
		@@connected_clients.reject { |c, v| self == c }
	end # other_peers

	def send_line(line)
		self.send_data("#{line}\n")
	end # send_line(line)
end

EventMachine.run do
	# hit Control + C to stop
	Signal.trap("INT")  { EventMachine.stop }
	Signal.trap("TERM") { EventMachine.stop }

	EventMachine.start_server("0.0.0.0", Util.port, SimpleChatServer)
end
