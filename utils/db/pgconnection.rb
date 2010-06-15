
require 'pg'

module Raser
	module Db
		class PgConnection
			attr_accessor :string, :schema
			def initialize &block
				#instance_eval &block if block
				yield self if block
				@conn = PGconn.new( @string )
				query "set search_path = #{@schema}" if @schema
			end
			def query q, *args
				@conn.query sprintf( q, *(args.map{ |s| escape_string(s) }) )
			rescue PGError => e
				p e
				nil
			end
			def query_one q, *args
				res = query q, *args
				#p res
				r = (res && res.first) ? correct_row(res.first) : nil
				res.clear if res
				r
			end
			def query_each q, *args
				res = query q, *args
				if res
					res.each do |row|
						correct_row row
						yield row
					end
					res.clear
				end
			end
			def escape_string s
				s.to_s.gsub( /[\']/ ) { |c| "''" }.gsub( /[\\\"\x00]/ ) { |c| ?\\ + c }
			end
			def correct_row row
				row.each_pair{ |k,e| e.force_encoding('utf-8') if e } if row.is_a? Hash
			end
		end
	end
end

