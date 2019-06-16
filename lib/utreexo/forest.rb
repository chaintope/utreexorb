module Utreexo

  class Forest

    # number of leaves in the forest (bottom row)
    attr_accessor :num_leaves

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

    # Delete element from forest.
    # @param [Utreexo::Proof] proofs the array of proof of element to be removed.
    def remove(proofs)
      n = nil
      h = 0
      while h < proofs.siblings.length do
        p = proofs.siblings[h]
        if !n.nil?
          n = parent(p, n)
        elsif acc[h].nil?
          acc[h] = p
        else
          n = proofs.right? ? parent(p, acc[h]) : parent(acc[h], p)
          acc[h] = nil
        end
        h += 1
      end
      acc[h] = n
    end

    # get current height of the highest tree
    # @return [Integer] current height of the highest tree
    def height
      i = acc.reverse.find_index{|i|!i.nil?}
      i ||= 0
      acc.length - i
    end

    private

    def parent(left, right)
      Blake2b.hex([left + right].pack('H*'))
    end

  end
end