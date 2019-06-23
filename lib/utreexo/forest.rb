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
        # Update siblings for tracking proofs
        p1 = find_proof(r)
        p1.each{|p|p.siblings << n}
        p2 = find_proof(n)
        p2.each{|p|p.siblings << r}

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
      @num_leaves -= 1
      # update acc hash
      is_switch = false
      while h < proof.siblings.length do
        s = proof.siblings[h]
        if !n.nil?
          n = ((1<<h) & proof.position) == 0 ? parent(n, s) : parent(s, n)
        elsif acc[h].nil?
          acc[h] = s
          p = proof(s)
          p.siblings.clear if p
        else
          # update siblings for switch case
          is_switch = true
          p0 = proof(acc[0])
          if p0
            p0.siblings = proof.siblings
            p0.position = proof.position
          end
          ps = proof(s)
          ps.siblings[0] = acc[0] if ps
          target = proof.payload
          new_target = acc[0]
          proof.siblings.each_with_index do |s, h|
            if ((1<<h) & proof.position) == 0
              target = parent(target, s)
              new_target = parent(new_target, s)
            else
              target = parent(s, target)
              new_target = parent(s, new_target)
            end
            proofs.select{|p|p.siblings.include?(target)}.each do |p|
              p.siblings[p.siblings.index(target)] = new_target
            end
          end

          n = proof.right? ? parent(s, acc[h]) : parent(acc[h], s)
          acc[h] = nil
        end
        h += 1
      end
      acc[h] = n

      # Update proofs
      proofs.delete(proof)
      remove_unnecessary_siblings!(proof)
      update_position!(proof) unless is_switch

      proofs.sort!{|a, b| a.position <=> b.position}
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

    # Get the current proof being tracked specified by leaf. If not tracking, return nil.
    # @param [String] leaf
    # @return [Utreexo::Proof]
    def proof(leaf)
      proofs.find{|p|p.payload == leaf}
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

    def remove_unnecessary_siblings!(proof)
      return unless proof.siblings.size > 0
      target = proof.payload
      proof.siblings.each_with_index do |s, h|
        target = ((1<<h) & proof.position) == 0 ? parent(target, s) : parent(s, target)
        proofs.select{|p|p.siblings.include?(target)}.each do |p|
          p.siblings = p.siblings[0...p.siblings.index(target)]
        end
      end
    end

    def update_position!(proof)
      proof_pos = proof.position
      start_index = 0
      height.times do |i|
        half_pos = ((num_leaves + 1) / (2 * (i + 1)))
        threshold = half_pos + start_index
        proofs.each do |p|
          next if p.position < start_index
          if (height - 1) == i
            p.position -= 1 if proof.left?
          elsif proof_pos < threshold
            if p.position >= threshold
              p.position -= half_pos
            else
              p.position += half_pos
            end
          end
        end
        proof_pos += half_pos if proof_pos < threshold
        start_index += half_pos
      end
    end

  end
end