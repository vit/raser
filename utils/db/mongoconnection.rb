# coding: UTF-8

%w[mongo time digest/sha1 unicode_utils].each {|r| require r}

module Raser
	module Db
		class MongoConnection
			attr_accessor :host, :db_name
			TS = -> { Time.now.utc.iso8601(10) }
			IdSeq = -> args=({}) {
				domain = (args[:domain] || 'localhost').to_s
				limit = (args[:size] || 40).to_i - 1
				-> { ( Digest::SHA1.new << domain+rand.to_s+TS[] ).to_s[0..limit] }
			}
			def initialize &block
				#instance_eval &block if block
				yield self if block
				@seq = IdSeq[domain: 'localhost', size: 12]
				@db = Mongo::Connection.new(@host).db(@db_name)
				#@coll = @db.collection(@coll_name)
			end
			def open_collection coll_name
			#	Collection.new @db, coll_name
				@db.collection(coll_name)
			end
=begin
			class Collection
				def initialize db, coll_name
					@db = db
					@coll = @db.collection(coll_name)
				end
				def clear
					@coll.remove
				end
				def find q, opts={}
					@coll.find q, opts
				end
				def insert data={}, opts={}
					@coll.insert data, opts
				end
				def update selector, document, options={}
					@coll.update selector, document, options
				end
				def remove selector={}, opts={}
					#@coll.remove selector, opts
					@coll.remove selector
				end
				def put id, data
					data['_id'] = id
					@coll.insert( data )
				end
				def post data
					put @seq[], data
				end
				def get id
					@coll.find_one({'_id' => id})
				end
			end
=end
		end
	end
end

