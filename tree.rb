require_relative 'node'

class Tree
  attr :root

  def initialize
    @root = nil
    make_orders
  end

  def balanced? node = @root
    if !node.nil?
      heights(node).uniq.length <= 2
      a = heights(node)
      a1 = a.uniq.length
      #b = balanced?(node.lefty)
      #c = balanced?(node.righty)
      a1 <= 2 #&& b & c
    else
      true
    end
  end

  def build_tree ints
    refined = ints.sort.uniq
    @root = build_tree_rec refined
  end

  def delete value
    target = find(value)
    if !target.nil?
      if !target.lefty.nil? && !target.righty.nil?
        delete_with_children(target)
      elsif !target.lefty.nil? || !target.righty.nil?
        delete_with_child(target)
      else
        delete_baren(target)
      end
    end
  end

  def depth node
    if find(node.data)
      @depth
    else
      -1
    end
  end

  def insert value
    newNode = find(value)
    if newNode.nil?
      if @root.nil?
        @root = newNode
      else
        insert_rec Node.new(value), @root
      end
    end
  end

  def find value
    target = Node.new(value)
    temp = @root
    @parent = nil
    @depth = 0
    until temp.nil? || temp == target
      @parent = temp
      @depth += 1
      target < temp ? temp = temp.lefty : temp = temp.righty
    end
    temp
  end

  def level_order #block
    if !@root.nil?
      nodes = [@root]
      values = []
      until nodes.size == 0
        node = nodes.shift
        nodes << node.lefty unless node.lefty.nil?
        nodes << node.righty unless node.righty.nil?
        block_given? ? yield(node) : values << node.data
      end
      values unless block_given?
    end
  end

  def pretty_print
    data_width = max_child(@root).data.to_s.length
    lines = []
    default_space = (@root.data.to_s.ljust(data_width, "─") + " ───┤").length

    revorder do |node| 
      #puts ("\t" * depth(node)) + node.data.to_s
      depth = depth(node)
      str = "#{node.data} "
      
      if node == @root
        str += "──"
      else
        @parent.lefty == node ? str.prepend("└ ") : str.prepend("┌ ")
      end
      
      if !node.lefty.nil? || !node.righty.nil?
        until default_space - str.length == 1
          str += "─"
        end
        if !node.lefty.nil? && !node.righty.nil?
          str += "┤"
        elsif !node.lefty.nil?
          str += "┐"
        else
          str += "┘"
        end
      else 
        str = str[0..str.index(" ─")]
      end
      
      str.prepend((" " * (default_space - 1)) * depth)
      lines.push(str.split(""))
    end

    for i in 1...lines.length - 1
      j = default_space - 1
      while j < lines[i].length
        if lines[i][j] == ' ' && !lines[i-1][j].nil?
          if "┐┌┤│".include?(lines[i-1][j])
            lines[i][j] = "│"
          end
          j += default_space - 1
        else
          break
        end
      end
    end
    lines.each {|line| puts line.join("")}
  end

  def rebalance
    t = Tree.new
    t.build_tree level_order
  end

  def rebalance!
    build_tree level_order
  end

 private

  def build_tree_rec ints
    if ints.length == 1
      Node.new(ints[0])
    elsif ints.length == 0
      nil
    else
      middle = ints.length/2
      node = Node.new(ints[middle])
      node.lefty = build_tree ints[0...middle]
      node.righty = build_tree ints[middle+1..-1]
      node
    end
  end

  def delete_baren target
    if @parent.nil?
      @root = nil
    elsif @parent.lefty == target
      @parent.lefty = nil
    else
      @parent.righty = nil
    end
  end

  def delete_with_child target
    if @parent.nil?
      if @root.lefty.nil?
        @root = @root.righty
      else
        @root = @root.lefty
      end
    elsif target < @parent
      if target.lefty.nil?
        @parent.lefy = target.righty
      else
        @parent.lefty = target.lefty
      end
    else
      if target.lefty.nil?
        @parent.righty = target.righty
      else
        @parent.righty = target.lefty
      end
    end      
  end

  def delete_with_children target
    max_left_child = max_child(target.lefty)
    delete(max_left_child.data)
    max_left_child.lefty = target.lefty unless target.lefty == max_left_child
    max_left_child.righty = target.righty
    
    find(target.data)
    if @parent.nil?
      @root = max_left_child
    elsif target < @parent
      @parent.lefty = max_left_child
    else
      @parent.righty = max_left_child
    end
  end

  def heights node = @root, level = 0, levels = []
    if node.nil?
      levels
    elsif !node.lefty.nil? || !node.righty.nil?
       levels << level + 1 if node.lefty.nil? || node.righty.nil?
      heights(node.lefty, level + 1, levels)
      heights(node.righty, level + 1, levels)
    else
      levels << level
    end
  end

  def insert_rec new_node, node
    if new_node < node
      node.lefty.nil? ? node.lefty = new_node : insert_rec(new_node, node.lefty)
    elsif new_node > node
      node.righty.nil? ? node.righty = new_node : insert_rec(new_node, node.righty)
    end
  end

  def make_orders #called in initializer
    prefixes = ["in", "pre", "post", "rev"]

    prefixes.each do |prefix|
      name = prefix + "order"
      parts = [
        "#{name}(node.lefty, values, &block)", 
        "block.nil? ? values << node.data : block.call(node)",
        "#{name}(node.righty, values, &block)"
        ]
      
      case prefix
      when 'pre'
        parts[0], parts[1] = parts[1], parts[0]
      when 'post'
        parts[1], parts[2] = parts[2], parts[1]
      when 'rev'
        parts[0], parts[2] = parts[2], parts[0]
      end

      self.class.send(:define_method, "#{prefix}order".to_sym) do |node=@root, values=[], &block|
        if !node.nil?
          eval(parts[0])
          eval(parts[1])
          eval(parts[2])
          block.nil? ? values : nil
        end
      end
    end
  end
  
  def max_child node
    if node.righty.nil?
      node
    else
      max_child(node.righty)
    end
  end

end

=begin

                ┌ 99 ────┐
                │        └ 92
       ┌ 83 ────┤
       │        │        ┌ 69
       │        └ 62 ────┤
       │                 └ 54
47 ────┤
       │                 ┌ 41
       │        ┌ 37 ────┤
       │        │        └ 34
       └ 22 ────┤
                │       ┌ 21
                └ 5 ────┤
                        └ 3

-

U+250C ┌, U+2514 └, U+2500 ─, U+2524 ┤, U+2510 ┐, U+2518 ┘, U+2502 │

if has children: ────
  if both: ┤
  elsif right: ┐
  elsif left: ┘
  end
end
immediate predecessor :
if left child: ┌
elsif right child: └ 
end
following predecessors
for every "in between" parent and superparent:  │

=end 
