require_relative 'tree'
require_relative 'node'
'''
t = Tree.new 
t.build_tree [1,2,3,5,6,7,8,10,11,12,13,14,15,17,20,21,22]
puts "Balanced: #{t.balanced?}"
t.pretty_print
t.delete(7)
t.delete(10)
t.delete(8)
t.pretty_print
puts "Balanced: #{t.balanced?}"
t.rebalance!
t.pretty_print
puts "Balanced: #{t.balanced?}"

'''
sample = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15] #Array.new(15) {rand(1..45)}  
tree = Tree.new
tree.build_tree sample
puts "Balanced: #{tree.balanced?}"
print "Inorder: "
tree.inorder { |node| print "#{node.data} "}
puts
print "Preorder: "
tree.preorder { |node| print "#{node.data} "}
puts
print "Postorder: "
tree.postorder { |node| print "#{node.data} "}
puts

tree.pretty_print
puts "Remove 9"
tree.delete(9)
tree.pretty_print
puts "Remove 4"
tree.delete(4)
tree.pretty_print

puts "add values to unbalance, remove node with one child, and rebalance"
tree.insert(16)
tree.insert(20)
tree.insert(17)
tree.insert(21)
tree.insert(22)
tree.pretty_print
puts "Remove 16"
tree.delete(16)
tree.pretty_print

puts "Balanced: #{tree.balanced?}"
puts "Rebalance"
tree.rebalance!
tree.pretty_print
puts "Balanced: #{tree.balanced?}"

