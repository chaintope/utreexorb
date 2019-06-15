module Utreexo

  class Forest

    # number of leaves in the forest (bottom row)
    attr_accessor :num_leaves

    # height of the forest. When there is only 1 tree in the forest, it is equal to the height of that tree (2**n nodes).
    #  If there are multiple trees, fullHeight will be 1 higher than the highest tree in the forest.
    attr_accessor :height

    # accumulator
    attr_accessor :acc

    def initialize
      @height = 0
      @num_leaves = 0
      @forest = []
      @acc = []
    end

    # Add element to forest.
    # @param [String] leaf an element hash to be added with hex format.
    def add(leaf)
      n = leaf
      h = 0
      r = acc[h]
      until r.nil? do
        n = parent(r, n)
        acc[h] = nil
        h += 1
        r = acc[h]
      end
      acc[h] = n
      @num_leaves += 1
    end

    # Recomputes all hashes above the first floor.
    def re_hash
      return if height == 0

    end

    def parent(left, right)
      Blake2b.hex([left + right].pack('H*'))
    end

    private

    def internal_add(hex)
      @forest[num_leaves] = hex
      @num_leaves += 1
    end

  end
end