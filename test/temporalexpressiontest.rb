#!/usr/bin/env ruby

$:<<'../lib'

require 'test/unit'
require 'runt'
require 'date'

=begin
  Author: Matthew Lipper
=end

class TemporalExpressionTest < Test::Unit::TestCase

	include Runt
	include DatePrecision

	def test_collection_te
    
		#base class that should always return false
		expr = CollectionTE.new
  
		assert(!expr.includes(Date.today))	
	
	end
	
	def test_union_te
	
		union_expr = UnionTE.new		
		
		#Everyday from midnight to 6:30am
		expr1 = RangeEachDayTE.new(0,0,6,30)		
		#First Tuesday of the month
		expr2 = DayInMonthTE.new(First,Tuesday)

		union_expr.add(expr1).add(expr2)
		
		#January 6th, 2004 (First Tuesday)
		assert(union_expr.includes?(TimePoint.day_of_month(2004,1,6)))		
		#4am (February, 8th, 1966 - ignored)
		assert(union_expr.includes?(TimePoint.hour_of_day(1966,2,8,4)))
		#6:31am, July, 4th, 2030
		assert(!union_expr.includes?(TimePoint.minute(2030,7,4,6,31)))
	end
	
	def test_arbitrary_te	
		expr1 = ArbitraryTE.new(TimePoint.day_of_month(2003,12,30))
		expr2 = ArbitraryTE.new(TimePoint.day_of_month(2004,1,1))  	
		assert(expr1.includes?(Date.new(2003,12,30)))	
		assert(!expr1.includes?(Date.new(2003,12,31)))
		assert(expr2.includes?(Date.new(2004,1,1)))
		assert(!expr2.includes?(Date.new(2003,1,1)))
	end
	
	def test_intersection_te
	
		#March through April
		expr1 = RangeEachYearTE.new(3,4)

		#First Sunday of any month
		expr2 = DayInMonthTE.new(First,Sunday)
		
		#Should match the first Sunday of March and April
		intersect_expr  = IntersectionTE.new
		intersect_expr.add(expr1).add(expr2)
		
		#Sunday, March 7th, 2004
		assert(intersect_expr.includes?(TimePoint.new(2004,3,7)))
		#First Sunday in February, 2004
		assert(!intersect_expr.includes?(TimePoint.new(2004,4,1)))


  end
	
	def test_day_in_month_te

		#Friday, January 16th 2004
		dt1 = Date.civil(2004,1,16)

		#Friday, January 9th 2004
		dt2 = Date.civil(2004,1,9)

		#third Friday of the month
		expr1 = DayInMonthTE.new(Third,Friday)

		#second Friday of the month
		expr2 = DayInMonthTE.new(Second,Friday)

		assert(expr1.includes?(dt1))
		
		assert(!expr1.includes?(dt2))	
			
		assert(expr2.includes?(dt2))	

		assert(!expr2.includes?(dt1))	

		#Sunday, January 25th 2004
		dt3 = Date.civil(2004,1,25)
		
		#last Sunday of the month
		expr3 = DayInMonthTE.new(Last_of,Sunday)
		
		assert(expr3.includes?(dt3))	
	end

	def test_range_each_year_te
		# November 1st, 1961
		dt1 = Date.civil(1961,11,1)

		#June, 1986
		dt2 = TimePoint::month(1986,6)
		
		#November and December
		expr1 = RangeEachYearTE.new(11,12)
		
		#May 31st through  and September 6th
		expr2 = RangeEachYearTE.new(5,31,9,6)

		assert(expr1.includes?(dt1))

		assert(!expr1.includes?(dt2))
		
		#~ expr2.print(dt2)
		
		assert(expr2.includes?(dt2))

	end
	
	def test_range_each_day_te
		#noon to 4:30pm
		expr1 = RangeEachDayTE.new(12,0,16,30)		
		#3:15 pm (May 8th, 2012 - ignored)
		assert(expr1.includes?(TimePoint.hour_of_day(2012,5,8,15,15)))
		#4:30 pm (April 18th, 1922 - ignored)
		assert(expr1.includes?(TimePoint.hour_of_day(1922,4,18,16,30)))
		#noon (June 5th, 1975 - ignored)
		assert(expr1.includes?(TimePoint.hour_of_day(1975,6,5,12,0)))
		#3:15 am (May 8th, 2012 - ignored)
		assert(!expr1.includes?(TimePoint.hour_of_day(2012,5,8,3,15)))
		
		#8:30pm to 12:00 midnite
		expr2 = RangeEachDayTE.new(20,30,00,00)		
		#9:00 pm (January 28th, 2004 - ignored)
		assert(expr2.includes?(TimePoint.minute(2004,1,28,21,00)))
		#12:00 am (January 28th, 2004 - ignored)
		assert(expr2.includes?(TimePoint.minute(2004,1,28,0,0)))
		#12:01 am (January 28th, 2004 - ignored)
		assert(!expr2.includes?(TimePoint.minute(2004,1,28,0,01)))		
	end
	
end