class Array
	def sum
		self.reduce(:+)
	end

	def average
		self.sum.to_f / self.size
	end
end

class Time 
	def to_ms
		(self.to_f * 1000).to_i
	end
end

class Util
	def self.port
		2000
	end

	def self.remove_prefix string
		string[5..-1].to_i
	end
end