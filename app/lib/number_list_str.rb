class NumberListStr
  def self.to_arr(str, total)
    return [] if str.nil?
    str.split(',').map{|x|
      t = x.split('-')
      Range.new([0, t[0].to_i].max, [t[-1].to_i, total - 1].min).to_a
    }.flatten.sort.uniq
  end

  def self.reduce(str, total)
    to_arr(str, total).chunk_while{|x, y|
      x + 1 == y
    }.map{|x|
      x.size == 1 ? x[0].to_s : x[0].to_s + '-' + x[-1].to_s
    }.join(',')
  end
end
