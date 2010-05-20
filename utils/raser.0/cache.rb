%w[memcached].each {|r| require r}

module Raser
	class Cache
		class Memcache
			class << self
				attr_accessor :servers
				def init
					yield self
					@cache = Memcached.new(@servers)
				end
				def set key, value, expire=60
					@cache.set key, value, expire if @cache
				rescue Memcached::Error
				end
				def get key
					@cache.get key if @cache
				rescue Memcached::Error
				end
				def delete key
					@cache.delete key if @cache
				rescue Memcached::Error
				end
			end
		end
	end
end


