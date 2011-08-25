
require 'pg'

module Raser
	module Db
		class PgConnection
			attr_accessor :string, :schema
			Params = {
				#string: '',
			#	string: nil,
			#	schema: nil,
				standard_conforming_strings: true
			}
			def initialize params={}, &block
				yield self if block
				@params = Params.merge({
					string: @string,
					schema: @schema
				}).merge params
				@conn = @params[:string] ? PGconn.new( @params[:string] ) : PGconn.connect( @params['conn'] )
				query "set search_path = #{@params['schema']}" if @params['schema']
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
				row = (res && res.first) ? correct_row(res.first) : nil
				res.clear if res
				#r
				(block_given? ? (yield row) : row)
			end
			def query_each q, *args
				res = query q, *args
				if res
					res.each do |row|
						correct_row row
						yield row if block_given?
					end
					res.clear
				end
			end
			def query_map q, *args
				arr = []
				res = query q, *args
				if res
					res.each do |row|
						correct_row row
						arr << (block_given? ? (yield row) : row)
					end
					res.clear
				end
				arr
			end
			def query_inject acc, q, *args
				res = query q, *args
				if res
					res.each do |row|
						correct_row row
						acc = (yield acc, row) if block_given?
					end
					res.clear
				end
				acc
			end
			def escape_string s
				s.to_s.gsub!( /[\']/ ) { |c| "''" }
				s.gsub!( /[\\\"\x00]/ ) { |c| ?\\ + c } unless @params[:standard_conforming_strings]
				s
			end
			def correct_row row
				row.each_pair{ |k,e| e.force_encoding('utf-8') if e } if row.is_a? Hash
			end
		end
	end
end

