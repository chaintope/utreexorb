module Utreexo

  class Forest

    # number of leaves in the forest (bottom row)
    attr_accessor :num_leaves

    # accumulator
    attr_reader :acc

    # tracking proofs
    attr_reader :proofs

    def initialize
      @num_leaves = 0
      @acc = []
      @proofs = []
    end

    # Add element to forest.
    # @param [String] leaf an element hash to be added with hex format.
    def add(leaf, track = false)
      n = leaf
      h = 0
      r = acc[h]
      proofs << Utreexo::Proof.new(num_leaves, leaf) if track
      until r.nil? do
        p1 = find_proof(r)
        p1.each{|p|p.siblings << n} unless p1.empty?
        p2 = find_proof(n)
        p2.each{|p|p.siblings << r} << r unless p2.empty?

        n = parent(r, n)
        acc[h] = nil
        h += 1
        r = acc[h]
      end
      acc[h] = n
      @num_leaves += 1
    end

    # Delete element from forest.
    # @param [Utreexo::Proof] proof the proof of element to be removed.
    def remove(proof)
      raise Utreexo::Error, 'The target element does not exist in the forest.' unless include?(proof)
      n = nil
      h = 0
      while h < proof.siblings.length do
        p = proof.siblings[h]
        if !n.nil?
          n = parent(p, n)
        elsif acc[h].nil?
          acc[h] = p
        else
          n = proof.right? ? parent(p, acc[h]) : parent(acc[h], p)
          acc[h] = nil
        end
        h += 1
      end
      acc[h] = n
    end

    # Whether the element exists in the forest
    # @param [Utreexo::Proof] proof the proof of element
    # @return [Boolean]
    def include?(proof)
      root = acc[proof.siblings.length]
      n = proof.payload
      proof.siblings.each_with_index do |sibling, height|
        if ((1<<height) & proof.position) == 0
          n = parent(n, sibling)
        else
          n = parent(sibling, n)
        end
      end
      n == root
    end

    # get current height of the highest tree
    # @return [Integer] current height of the highest tree
    def height
      i = acc.reverse.find_index{|i|!i.nil?}
      i ||= 0
      acc.length - i
    end

    private

    # Calculate parent hash
    # @param [String] left left node hash with hex format.
    # @param [String] right left node hash with hex format.
    # @return [String] a parent hash with hex format.
    def parent(left, right)
      Blake2b.hex([left + right].pack('H*'))
    end

    # Calculate the proof associated with the target(self or parent).
    # @param [String] target a target hash.
    # @return [Array[Utreexo::Proof]] target proofs.
    def find_proof(target)
      proofs.select do |p|
        n = p.payload
        p.siblings.each_with_index do|s, h|
          if ((1<<h) & p.position) == 0
            n = parent(n, s)
          else
            n = parent(s, n)
          end
        end
        n == target
      end
    end

  end
end