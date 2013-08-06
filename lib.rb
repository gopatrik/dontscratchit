class Util
	def self.port
		2000
	end

	def self.millis
		(Time.now.nsec/10e6).to_i
	end
end