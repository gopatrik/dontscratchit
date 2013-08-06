require 'eventmachine'
require 'json'

class SimpleChatServer < EM::Connection

  @@connected_clients = Array.new

  attr_reader :username
  
  #
  # EventMachine handlers
  #

  def post_init
  	@@connected_clients << self
    puts "A client has connected..."
  end

  def unbind
    @@connected_clients.delete(self)
    puts "A client has left..."
  end

  def receive_data(data)
  	  begin
  	  	data = JSON.parse(data.strip)
  	  	self.announce data, true
  	  	p data
  	  rescue
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

  EventMachine.start_server("0.0.0.0", 2000, SimpleChatServer)
end