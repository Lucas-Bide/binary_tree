class Node
  include Comparable
  attr_accessor :data, :lefty, :righty

  def initialize(data, lefty=nil, righty=nil)
    @data = data
    @lefty = lefty
    @righty = righty
  end

  def <=> other
    @data <=> other.data
  end
end
