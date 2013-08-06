class Time 
	def to_ms
		(self.to_f * 1000).to_i
	end
end

class Util
	def self.port
		2000
	end
end