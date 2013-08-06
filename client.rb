require 'socket' # Sockets are in standard library
require 'net/telnet'
require 'json'

hostname = '192.168.1.9'
port = 2000

# "%X telnet 192.168.1.9 2000

server = TCPSocket.open hostname, port

json_object = {
	"name" => +0,
	"value" => -0
  }.to_json

server.puts json_object 

puts server.gets.chomp

