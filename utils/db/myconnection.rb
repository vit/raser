
require 'mysql'

module Raser
	module Db
		class MyConnection
			attr_accessor :table
			Params = {
				#string: '',
			#	string: nil,
			#	schema: nil,
		#		standard_conforming_strings: true
			}
			def initialize params={}, &block
				yield self if block
				@params = Params.merge({
					'host' => '127.0.0.1',
					'user' => '',
					'passwd' => '',
					'db' => '',
					'port' => 9306,
					'sock' => nil,
					'flag' => 0
				}).merge params
				@table = @params['table']
			#	p @params
				connect
			#	query "set search_path = #{@params['schema']}" if @params['schema']
			end
			def connect
				@conn = Mysql.real_connect(
					@params['host'],
					@params['user'],
					@params['passwd'],
					@params['db'],
					@params['port'],
					@params['sock'],
					@params['flag']
				)
				@conn.reconnect = true
			end
			def query q, *args
				cnt = 5
				begin
					@conn.query sprintf( q, *(args.map{ |s| escape_string(s) }) )
				#rescue PGError => e
				rescue Exception => e
					p e
					cnt -= 1
					retry if cnt >= 0
					nil
				end
			end
=begin
			def query_one q, *args
				res = query q, *args
				#p res
				row = (res && res.first) ? correct_row(res.first) : nil
				res.clear if res
				#r
				(block_given? ? (yield row) : row)
			end
=end
			def query_each q, *args
				res = query q, *args
				if res
					#res.each do |row|
					res.each_hash do |row|
						correct_row row
						yield row if block_given?
					end
					res.free
				end
			end
=begin
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
=end
			def escape_string s
				@conn.quote s
#				s.to_s.gsub!( /[\']/ ) { |c| "''" }
#				s.gsub!( /[\\\"\x00]/ ) { |c| ?\\ + c } unless @params[:standard_conforming_strings]
#				s
			end
			def correct_row row
				row.each_pair{ |k,e| e.force_encoding('utf-8') if e } if row.is_a? Hash
			end
		end
	end
end

