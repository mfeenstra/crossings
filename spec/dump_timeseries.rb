#!/usr/bin/env ruby
require "#{ENV['HOME']}/marketmath/config/environment"

b = GET.call('blbd')

# price data
prices = b.last(250)
outfile = File.open('prices.txt', 'w')
prices.each_with_index { |d,i| outfile.puts "#{i} #{d}" }; outfile.close

# projected data
outfile = File.open('projected.txt', 'w')
b.projected_price.last(30).each.with_index(220) { |day,i| outfile.puts "#{i} #{day}" }; outfile.close

# rolling average
outfile = File.open('r30.txt', 'w')
r30 = b.average_price.last(250).map { |p| p.value }
r30.each_with_index { |d,i| outfile.puts "#{i} #{d}" }; outfile.close

# trailing 5 day moving average
day5 = b.average_price.last(250).map { |p| p.trailing_5d }
outfile = File.open('t5.txt', 'w')
day5.each_with_index { |d,i| outfile.puts "#{i} #{d}" }; outfile.close

# trailing 10
day10 = b.average_price.last(250).map { |p| p.trailing_10d }
outfile = File.open('t10.txt', 'w')
day10.each_with_index { |d,i| outfile.puts "#{i} #{d}" }; outfile.close

# trailing 20
day20 = b.average_price.last(250).map { |p| p.trailing_20d }
outfile = File.open('t20.txt', 'w')
day20.each_with_index { |d,i| outfile.puts "#{i} #{d}" }; outfile.close

# trailing 50
day50 = b.average_price.last(250).map { |p| p.trailing_50d }
outfile = File.open('t50.txt', 'w')
day50.each_with_index { |d,i| outfile.puts "#{i} #{d}" }; outfile.close

# trailing 100
day100 = b.average_price.last(250).map { |p| p.trailing_100d }
outfile = File.open('t100.txt', 'w')
day100.each_with_index { |d,i| outfile.puts "#{i} #{d}" }; outfile.close

# trailing 200
day200 = b.average_price.last(250).map { |p| p.trailing_200d }
outfile = File.open('t200.txt', 'w')
day200.each_with_index { |d,i| outfile.puts "#{i} #{d}" }; outfile.close


#b = GET.call 'Yblbd'; day5 = b.average_price.last(250).map { |p| p.trailing_5d }; outfile = File.open('t5.txt', 'w'); day5.each_with_index { |d,i
#| outfile.puts "#{i} #{d}" }; outfile.close
