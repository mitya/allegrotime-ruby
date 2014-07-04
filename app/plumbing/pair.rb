class Pair
  attr_accessor :first, :second
  
  def initialize(first, second)
    @first = first
    @second = second
  end
  
  def inspect
    "(#{first}, #{second})"
  end
  
  def ==(other)
    self.first == other.first && self.second == other.second
  end
  
  alias === ==
end
