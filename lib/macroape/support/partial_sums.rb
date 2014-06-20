class Array
  def partial_sums(initial = 0.0)
    sums = initial
    map{|el| sums += el}
  end
end

class Hash
# {1 => 5, 4 => 3, 3 => 2}.partial_sums == {1=>5, 3=>7, 4=>10}
  def partial_sums(initial = 0.0)
    sums = initial
    sort.each_with_object({}){|(k,v), hsh|
      sums += v
      hsh[k] = sums
    }
  end
end
