module Utreexo
  class Proof

    attr_accessor :position # where at the bottom of the tree it sits
    attr_reader :payload    # hash of the thing itself (what's getting proved)
    attr_accessor :siblings   # hash of siblings up to a root

    # initialize
    # @param [Integer] position Where at the bottom of the tree it sits
    # @param [String] payload Target element
    # @param [Array[String]] siblings proofs
    def initialize(position, payload, siblings = [])
      @position = position
      @payload = payload
      @siblings = siblings
    end

    # Whether the element is a node on the right
    # @return [Boolean]
    def right?
      position.odd?
    end

    # Whether the element is a node on the left
    # @return [Boolean]
    def left?
      position.even?
    end

    # Show proof
    def to_s
      "[#{position}] leaf = #{payload}, siblings = #{siblings}"
    end

    # Return tree height containing this element
    # @return [Integer] tree height
    def tree_height
      siblings.size
    end

    # Returns the number of leaves in the tree that contains this element.
    # @return [Integer] the number of leaves in the tree
    def tree_leaves
      2 ** tree_height
    end

    # Return the position of this proof's pair leaf.
    # @return [Integer] the position of this proof's pair leaf
    def pair_pos
      right? ? position - 1 : position + 1
    end

    # Returns the position of the leaf that is switched together with this proof, when switching this proof.
    # @param [Integer] leaves the number of leaves to be switched.
    # @return [Range] Leaf range to be switched.
    def switch_range(leaves)
      l = tree_leaves
      unit = l / leaves
      unit.times do |i|
        range = ((i * leaves)...((i + 1) * leaves))
        return range.first..(range.last - 1) if range.include?(position)
      end
    end

    # When replacing the parent of +height+ of this proof with +parent+ argument, returns the list of parent nodes to be updated.
    # @param [String] parent the parent value to replace
    # @param [Integer] parent_height the parent height to replace
    # @return [Array[String]] a list of updated parents
    def switched_parents(parent, parent_height)
      n = parent
      (tree_height - parent_height).times.map do |i|
        if ((1<<(i + parent_height)) & position) == 0
          n = Utreexo.parent(n, siblings[parent_height + i])
        else
          n = Utreexo.parent(siblings[parent_height + i], n)
        end
        n
      end
    end

    # Get the height at which the leaves of +pos+ will be the same tree as the leaves of this proof.
    # @param [Integer] pos target position
    # @return [Integer] height
    def same_subtree_height(pos)
      raise Utreexo::Error, "pos: #{pos} does not in tree." unless (0...tree_leaves).include?(pos)
      return 0 if position == pos
      (tree_height + 1).times do |i|
        same_group = false
        groups = tree_leaves / (2 ** i)
        (tree_leaves / groups).times do |j|
          group = ((groups * j)...(groups * (j + 1)))
          same_group = true if group.include?(position) && group.include?(pos)
        end
        return  tree_height - (i - 1) unless same_group
      end
    end

  end
end