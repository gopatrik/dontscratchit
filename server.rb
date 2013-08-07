require 'eventmachine'
require 'json'
require_relative 'lib'

class Board
	def initialize()
		@board = Array.new 256, false
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

			print "[#{square ? 'X' : ' '}] "
		end
		3.times do puts end
	end

	def to_json(*a)
		@board.to_json(*a)
	end
end


class SimpleChatServer < EM::Connection

	@@connected_clients = Hash.new
	@started = false
	@@time_started = nil
	@@lap_time = 16 * (30/132)

	# @@board = Board.new
	
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
			:offset => 0,
			:boards => [Board.new, Board.new],
			:client_id => get_sockname.to_i.to_s
		}
		# 30 / 132 = ett beat
		# ett varv = 16 * (30/132) (sekunder)
		self.send_line all_clients_data unless other_peers.empty?

		self.the_loop unless @started
		
		puts "A client has connected..."
		self.announce "CLIENTID:#{get_sockname}"
		if @@connected_clients.size == 1
			@@time_started = Time.now.to_ms
			Thread.start { cycle }
			
		end
	end

	def all_clients_data
		data = Array.new
		other_peers.each do |scs, client|
			index = { :client_id => client[:client_id],
								:boards => Array.new }
			client[:boards].each do |board|
				index[:boards] << board
			end
			data << index
		end
		data.to_json
	end

	def unbind
		@@connected_clients.delete(self)
		puts "A client has left..."
	end

	def next_lap
		Time.now.to_ms - (@@time_started + @@lap_time * 1000)
	end

	def next_beat client
		"DIFF:#{next_lap}" #+ @@connected_clients[client][:offset]}
	end

	def cycle
		
			loop do
				puts "ASD = #{@@lap_time}"
				puts "Hello: #{next_beat}"
				sleep(@@lap_time)
				@@time_started = Time.now.to_ms
				self.announce "#{next_beat}", true
			end
	end

	def receive_data(data)
		if data.start_with? "TIME"
			@@connected_clients[self][:offset] = Util.remove_prefix data
		else
			begin
				data = JSON.parse(data.strip)
				data[:client_id] = get_sockname.to_i.to_s
				self.announce data.to_json
				id = self.read_data data["diff"]

				puts "#{data['name']} changed board #{id}!" unless data["name"].nil?
				get_board(id).draw
			rescue Exception => e
				p e
				self.send_line e
			end
		end
	end

	def read_data data
		board = get_board(data["board_id"])
		board.parse_diff data["squares"]
		data["board_id"]
	end

	def get_board id
		@@connected_clients[self][:boards][id]
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
