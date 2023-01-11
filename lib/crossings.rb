class Crossings

  ### Usage: ###########################################################################################################
  #
  # For crossings of the first time series, relative to the second (arrays):
  #   object = Crossings.new ( fast_response_series1, slower_response_series2 )
  #
  # Returns the indices where series1 exhibits golden and death crosses:
  #   { golden: [ index1, index2, .. ],
  #     death:  [ indexA, indexB, .. ] }
  #
  ######################################################################################################################
  # For finding where 2 different timeseries cross, if at all.  If there is such crossing, we need to know whether
  #   the first series crosses from:
  #
  #   1) below and up through the second, or
  #   2) from above and down through the second
  #
  # Hereafter, the first series is called "fast_timeseries" and the second referred to as "slow_timeseries".  The
  #   indices where the data is crossing up, or crossing down, will be referred to as the "golden cross" and the 
  #   "death cross", respectively.
  #
  # starting with the fast timeseries, for 3 points in a row, compare to the slow timeseries to the fast 
  #   and see if we've moved up through it, down below it, or neither (staying (relatively) "parallel", above or below),
  #   by looking at the following cases:
  #
  # for ex, 3 consecutive points, middle being index n like (n-1, n, n+1) <-- same relative position
  #   for both fast and slow timeseries..
  # if fast is like (a, b, c) and slow is like (A, B, C) and from the perspective of n middle index (at b/B)
  #   (read left to right, a b c, as conseective values for time-points in the series)
  #
  # ----- 4 conditions may exist -----
  #
  # fast is moving above the slow (parallel), then the following condition is true (no crossing) -
  #   a > A, b > B, c > C
  #
  # fast is crossing down through the slow (down slope), then it IS a 'death' crossing -
  #   a > A, b ~ B, c < C
  #
  # fast is below the slow (parallel), then (no crossing here) -
  #   a < A, b < B, c < C
  #
  # fast is moving from below the slow and crossing upto above it, or 'golden' crossing -
  #   a < A, b ~ B, c > C
  #
  # ----------------------------------
  #
  # Returns: indices of golden + death crossings as a hash, for exmaple:
  #   crossings = { gold: [1,20,300], death: [5, 30, 250] }
  #
  # --------------------------------------------------------------------------------------------------------------------
  # Copyright 2023, All Rights Reserved.
  #   matt.a.feenstra@gmail.com
  #   matt@feenstra.io
  ######################################################################################################################

  attr_reader :size, :fast_timeseries, :slow_timeseries, :crossings, :state

  def initialize(series1 = [], series2 = [])
    cn = self.class.name
    unless series1.is_a?(Array) && series2.is_a?(Array)
      raise "ERROR! [#{cn}] both series must be Arrays! " \
            "(#{series1.class}, #{series2.class})"
    end
    unless (series1.size >= 3) && (series2.size >= 3)
      raise "ERROR! [#{cn}] both series must have at minimum 3 points! " \
            "(#{series1.size}, #{series2.size})"
    end
    unless series1.size == series2.size
      raise "ERROR! [#{cn}] both series must have the same size! " \
            "(1st: #{series1.size} vs. 2nd: #{series2.size})"
    end
    puts "Crossings initializing.."

    # ensure cast to float, initialize vars.
    @fast_timeseries = series1.map { |n| n.to_f }
    @slow_timeseries = series2.map { |n| n.to_f }
    @size = series1.size
    @state = []
    @crossings = { golden: [], death: [] }
  end

  # march through, do the thing, avoiding both endpoints of the range
  # returns: crossings hash
  def perform
    @size.times do |i|
      next if (i == 0) || ( i == (@size - 1) )
      if golden_crossing(i)
        @crossings[:golden] << i
        next
      end
      if death_crossing(i)
        @crossings[:death] << i
        next
      end
    end
    @crossings
  end

  # debug outut, state for each index in series 1 relative to 2
  #   just so we know that it works.
  # returns: hash of states per index element
  def info
    state = []
    @size.times do |i|
      next if (i == 0) || ( i == (@size - 1) )
      state <<  { "#{i}": { value: @fast_timeseries[i],
                      parallel_above: parallel_above(i),
                      parallel_below: parallel_below(i),
                      negative_slope: negative_slope?(i),
                      positive_slope: positive_slope?(i),
                      golden_crossing: golden_crossing(i),
                      death_crossing: death_crossing(i),
                      both_crossings: ((golden_crossing(i) && death_crossing(i)) ? true : false),
                      above_and_below: ((parallel_above(i) && parallel_below(i)) ? true : false),
                      negative_and_positive: ((negative_slope?(i) && positive_slope?(i)) ? true : false)  } }
    end
    state
  end

  # trim down to 4 or less significant figures (for purposes of comparison, discrete series).
  # return: 6 element array where elements are like:
  #   0 through 2 are series 1, and
  #   3 through 5 are the second series w/ adjacent points
  #   the series' 1 & 2 central values are at index locations 1 and 4, respectively
  def fixed_precision(index)
    return nil if bad_range_check(index)
    i = index
    [ adjusted(@fast_timeseries[i-1]),
      adjusted(@fast_timeseries[i]),
      adjusted(@fast_timeseries[i+1]),
      adjusted(@slow_timeseries[i-1]),
      adjusted(@slow_timeseries[i]),
      adjusted(@slow_timeseries[i+1]) ]
  end

  # if the (index and adjacent points are all above the timeseries
  # returns: true/false
  # requires: timeseries index location of where we want to know
  def parallel_above(index)
    return nil if bad_range_check(index)
    i = index
    # s1/s2 - fast/slow series, with s1_02 / s2_02 being the middle elements Adjusting precision..
    s1_01, s1_02, s1_03, s2_01, s2_02, s2_03 = fixed_precision(i)
    if (s1_01 >= s2_01) && (s1_02 >= s2_02) && (s1_03 >= s2_03)
      return true
    end
    false
  end

  def parallel_below(index)
    return nil if bad_range_check(index)
    i = index
    # s1/s2 - fast/slow series, with s1_02 / s2_02 being the middle elements Adjusting precision..
    s1_01, s1_02, s1_03, s2_01, s2_02, s2_03 = fixed_precision(i)
    if (s1_01 <= s2_01) && (s1_02 <= s2_02) && (s1_03 <= s2_03)
      return true
    end
    false
  end

  def death_crossing(index)
    return nil if bad_range_check(index)
    i = index
    if !parallel_above(i) && !parallel_below(i) && negative_slope?(i) &&
       (@fast_timeseries[i] > @slow_timeseries[i])
      return true
    end
    false
  end

  def golden_crossing(index)
    return nil if bad_range_check(index)
    i = index
    if !parallel_above(i) && !parallel_below(i) && positive_slope?(i) &&
       (@fast_timeseries[i] < @slow_timeseries[i])
      return true
    end
    false
  end

  # series 1 is what we are comparing from the start
  def negative_slope?(index)
    return false if bad_range_check(index)
    if slope(@fast_timeseries[index - 1], @fast_timeseries[index + 1]) <= 0.0
      return true
    end
    false
  end

  def positive_slope?(index)
    return false if bad_range_check(index)
    if slope(@fast_timeseries[index - 1], @fast_timeseries[index + 1]) >= 0.0
      return true
    end
    false
  end

  ######################################################################################################################
  private

  def bad_range_check(index)
    if (index < 1) || (index >= (@size - 1))
      STDERR.puts "ERROR! [#{self.class.name}] [#{caller.first}] bad index: #{index}"
      return true
    end
    false
  end

  # slope = m from equation of a line y = mx + b and m = (y2-y1)/(x2-x1)
  # consecutive timeseries points make the denominator 1
  def slope(point1, point2)
    adjusted(point2) - adjusted(point1)
  end

  def adjusted(precise_price)
    precise_price.round(sigfigs(precise_price))
  end

  # sigfigs is the our parameter to ruby's 'round' function. This helps to 
  #   minimize too much precision and rounding error in comparison of dollar amts.
  #
  # requires: dollar price
  # returns: number of decimal places to consider relevant (4 is pretty much ideal)
  def sigfigs(price)
    dmag = price.round.to_s.size
    case
    when dmag <= 1
      return 4
    when dmag == 2
      return 3
    when dmag == 3
      return 2
    when dmag == 4
      return 1
    when dmag >= 5
      return 0
    else
      return 2
    end
  end

end
