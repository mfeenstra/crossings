require 'crossings'

describe Crossings do

  before(:context) do
    puts "STARTING UP."
    puts __dir__
    # BLBD (bluebird) market closing prices, with rolling and trailing averages (NYSE).
    #   prices.txt  projected.txt  r30.txt  t100.txt  t10.txt  t200.txt  t20.txt  t50.txt  t5.txt
    @prices = (File.readlines "#{__dir__}/fixtures/prices.txt").map { |l| l.split.last.to_f }
    @projected = (File.readlines "#{__dir__}/fixtures/projected.txt").map { |l| l.split.last.to_f }
    @r30 = (File.readlines "#{__dir__}/fixtures/r30.txt").map { |l| l.split.last.to_f }
    @t200 = (File.readlines "#{__dir__}/fixtures/t200.txt").map { |l| l.split.last.to_f }
    @t100 = (File.readlines "#{__dir__}/fixtures/t100.txt").map { |l| l.split.last.to_f }
    @t50 = (File.readlines "#{__dir__}/fixtures/t50.txt").map { |l| l.split.last.to_f }
    @t20 = (File.readlines "#{__dir__}/fixtures/t20.txt").map { |l| l.split.last.to_f }
    @t10 = (File.readlines "#{__dir__}/fixtures/t10.txt").map { |l| l.split.last.to_f }
    @t5 = (File.readlines "#{__dir__}/fixtures/t5.txt").map { |l| l.split.last.to_f }
  end

  describe 'some fixture data validation for sanity\'s sake' do
    it 'should find all the fixture data has the same length (not including projection)' do
      series_size = @prices.size
      expect( (@r30.size == series_size) && (@t5.size == series_size) && (@t10.size == series_size) &&
              (@t20.size == series_size) && (@t50.size == series_size) && (@t100.size == series_size) &&
              (@t200.size == series_size)
            ).to be(true)
    end
    it 'should raise exception if arrays are mismatched' do
      expect { Crossings.new( [0,1,2], [5,4,3,2,1] ) }.to raise_error(RuntimeError)
    end
    it 'should raise exception if something other than Array is passed to it' do
      expect { Crossings.new( 'this is a string', ['my', 'array'] ) }.to raise_error(RuntimeError)
    end
  end

  describe 'validate using price data versus 200day moving average' do
    it 'should find that blbd price on 01-04-2023 forms golden cross with 200d ma' do
      obj = Crossings.new(@prices, @t200)
      x = obj.perform
      puts x
      expect(x[:golden].size >= 1).to be(true)
    end
    it 'should be able to debug dump the info' do
      obj = Crossings.new(@prices, @t200)
      # puts obj.info
      expect(obj.is_a?(Crossings)).to be(true)
    end
    it 'should find that no single point is both golden or death crossing at the same time' do
      obj = Crossings.new(@prices, @t200)
      both = false
      info = obj.info
      info.each do |nfo|
        if nfo[:both_crossings]
          both = true
          break
        end
      end
      expect(both).to be(false)
    end
    it 'should find that no single point has both positive and negative slope at the same time' do
      obj = Crossings.new(@prices, @t200)
      both = false
      info = obj.info
      info.each do |nfo|
        if nfo[:negative_and_positive]
          both = true
          break
        end
      end
      expect(both).to be(false)
    end
    it 'should find that no single point is both above and below the second series line at the same time' do
      obj = Crossings.new(@prices, @t200)
      both = false
      info = obj.info
      info.each do |nfo|
        if nfo[:above_and_below]
          both = true
          break
        end
      end
      expect(both).to be(false)
    end
  end

  describe 'more validation with rolling 30-day and trailing 50-day timeseries' do
    it 'validate golden crosses in the rolling 30 and 50 day moving averages' do
      obj = Crossings.new(@r30, @t50)
      result = obj.perform
      puts result[:golden]
      expect(result[:golden].size >= 1).to be(true)
    end
    it 'validate death crosses in the rolling 30 and 50 day moving averages' do
      obj = Crossings.new(@r30, @t50)
      result = obj.perform
      puts result[:death]
      expect(result[:death].size >= 1).to be(true)
    end
  end

end
