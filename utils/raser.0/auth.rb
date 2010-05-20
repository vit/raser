%w[rack forwardable].each {|r| require r}

module Raser
	class User
		class << self
			def getInfo key
				{fname: 'v', lname: 's'}
			end
		end
		class Auth
			class << self
				attr_accessor :target, :cache
				extend Forwardable
				#def_delegator :@target, :checkSessionKey
				def_delegator :@target, :createSessionKey
				def_delegator :@target, :dropSessionKey
				def_delegator :@target, :checkUser
				def_delegator :@target, :checkUserAndCreateSessionKey
				def checkSessionKey key
					sk = 'session_key:'+key.to_s
					id = @cache ? @cache.get(sk) : nil
						#puts "From cache: #{id}" if id
					unless id
						id = @target.checkSessionKey key
						@cache.set(sk, id, 120) if @cache && id
					end
					id
				end
			end
			KEY_COOKIE_NAME = 'SESSION_KEY'
			class RackMiddleware
				def initialize(app)
					@app = app
				end
				def call(env)
					req = Rack::Request.new(env)
					session_key = req.cookies[KEY_COOKIE_NAME]
					puts session_key
					if session_key
						user_id = User::Auth.checkSessionKey session_key
						if user_id
							env['user_id'] = user_id
							env['session_key'] = session_key
						end
					end
					status, headers, body = @app.call(env)
					resp = Rack::Response.new body, status, headers
						env['session_key'] = 5678 # must be removed later
					#if env['session_key']
						resp.set_cookie( KEY_COOKIE_NAME, {:path => '/', :value => env['session_key'] } )
					#else
					#	resp.delete_cookie( KEY_COOKIE_NAME, {:path => '/'} )
					#end
					resp.finish
				end
			end
		end
	end
end


