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

	@@connected_clients = Array.new
	@started = false

	@@board = Board.new

	attr_reader :username
	
	#
	# EventMachine handlers
	#

	def the_loop
		@started = true
		 Thread.start() do
			loop do
				sleep(1)
				self.announce(Util.micros.to_s, true)
			end
		 end
	end

	def post_init
		@@connected_clients << self
		self.the_loop unless @started
		puts "A client has connected..."
	end

	def unbind
		@@connected_clients.delete(self)
		puts "A client has left..."
	end

	def receive_data(data)
			begin
				data = JSON.parse(data.strip)
				self.announce data


				@@board.parse_diff data["diff"]
				puts "#{data['name']} changed the board!" unless data["name"].nil?
				@@board.draw
			rescue Exception => e
				p e
				self.send_line "You suck!"
			end
	end

	#
	# Message handling
	#

	def handle_chat_message(msg)
		if command?(msg)
			self.handle_command(msg)
		else
			self.announce(msg, "#{@username}:")
		end
	end


	#
	# Helpers
	#

	def announce(msg = nil, all = false)
		if all
			@@connected_clients.each { |c| c.send_line("#{msg}") } unless msg.empty?
		else
			self.other_peers.each { |c| c.send_line("#{msg}") } unless msg.empty?
		end
	end

	def other_peers
		@@connected_clients.reject { |c| self == c }
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
