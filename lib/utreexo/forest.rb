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

        n = Utreexo.parent(r, n)
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
      fl = forest_leaves
      # update acc hash
      is_switch = false
      has_single_leaf = !acc[0].nil?
      while h < proof.siblings.length do
        s = proof.siblings[h]
        if !n.nil?
          n = ((1<<h) & proof.position) == 0 ? Utreexo.parent(n, s) : Utreexo.parent(s, n)
        elsif acc[h].nil?
          acc[h] = s
        else
          # pickup switch pair
          is_switch = true
          if has_single_leaf
            switch_single_leaf(proof, s)
          else
            switch_leaf_block(proof, fl, h)
          end
          n = (((1<<h) & proof.position) == 0) ? Utreexo.parent(acc[h], s) : Utreexo.parent(s, acc[h])
          acc[h] = nil
        end
        h += 1
      end
      acc[h] = n

      proofs.sort!{|a, b| a.position <=> b.position}
      proofs.delete(proof)

      # Update proofs
      remove_unnecessary_siblings!(proof)
      update_position!(proof) unless  is_switch

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
          n = Utreexo.parent(n, sibling)
        else
          n = Utreexo.parent(sibling, n)
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
    def highest_height
      i = acc.reverse.find_index{|i|!i.nil?}
      i ||= 0
      acc.length - i
    end

    # show forest
    def to_s
      h = highest_height
      outs = []
      index = 0
      h.times do |i|
        diff = Math.log2(num_leaves) == (h - 1) ? i + 1 : i
        row_len = 1 << (h - diff)
        out = ''
        line = ''
        row_items = (num_leaves / (2**i))
        row_len.times do |j|
          out << "#{index.to_s.rjust(2, '0')}:"
          node = (j.even? && (row_items - 1) == j) ? acc[i] : find_node(i, j)
          out << (node ? "#{node[0..3]} " : "???? ")
          out << (" " * (2 ** (3 + i)))[0...-8]
          index += 1
          break if (j + 2) > row_items
        end
        outs << out
        break if i == (h - 1)
        (row_len / 2).times do
          line << '|'
          line << ('--------' * (2 ** (i))).chop
          line << "\\"
          line << (" " * (2 ** (3 + i))).chop
        end
        outs << line
      end
      outs.reverse.join("\n")
    end

    private

    def find_node(height, index)
      return find_proof_at(index)&.payload if height == 0
      return acc[self.highest_height - 1] if height == (self.highest_height - 1)
      if height == 1
        p1 = find_proof_at(index * 2)
        return Utreexo.parent(p1.payload, p1.siblings[0]) if p1
        p2 = find_proof_at(index * 2 + 1)
        return Utreexo.parent(p2.siblings[0], p2.payload) if p2
      end
      left_pos = (2 ** height) * index
      if index.even?
        left_pos += (2 ** height)
      else
        left_pos -= (2 ** height)
      end
      right_pos = left_pos + (2 ** height - 1)
      targets = proofs.select{|p| left_pos <= p.position && p.position <= right_pos}
      p = targets.find{|p|!p.siblings[height].nil?}
      p.siblings[height] if p
    end

    # Calculate the proof associated with the target(self or parent).
    # @param [String] target a target hash.
    # @return [Array[Utreexo::Proof]] target proofs.
    def find_proof(target)
      proofs.select do |p|
        n = p.payload
        p.siblings.each_with_index do|s, h|
          if ((1<<h) & p.position) == 0
            n = Utreexo.parent(n, s)
          else
            n = Utreexo.parent(s, n)
          end
        end
        n == target
      end
    end

    def find_proof_at(index)
      proofs.find{|p|p.position == index}
    end

    def remove_unnecessary_siblings!(proof)
      return unless proof.siblings.size > 0
      target = proof.payload
      proofs.select{|p|p.siblings.include?(target)}.each do |p|
        p.siblings = p.siblings[0...p.siblings.index(target)]
      end
      proof.siblings.each_with_index do |s, h|
        target = ((1<<h) & proof.position) == 0 ? Utreexo.parent(target, s) : Utreexo.parent(s, target)
        proofs.select{|p|p.siblings.include?(target)}.each do |p|
          p.siblings = p.siblings[0...p.siblings.index(target)]
        end
      end
    end

    # update position
    # @param [Utreexo::Proof] proof removed proof
    def update_position!(proof)
      proof_pos = proof.position
      start_index = 0
      h = highest_height
      h.times do |i|
        half_pos = 2 ** (h - (i + 1))
        threshold = half_pos + start_index
        proofs.each do |p|
          next if p.position < start_index
          if (highest_height - 1) == i
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

    # Get the number of leaves of each tree in the forest in ascending order.
    # @return [Array[Integer]] the number of leaves of each tree in the forest.
    def forest_leaves
      acc.map.with_index{|a, i| a.nil? ? nil : 2 ** i}.compact.reverse
    end

    # Get the start index and end index of the leaf of the tree with the target leaf number in the forest.
    # @param [Integer] forest_trees the number of leaves of each tree in the forest.
    # @param [Integer] target_tree Number of leaves in target tree.
    # @return [Range] start index and end index at the target tree.
    def target_tree_range(forest_trees, target_tree)
      i = forest_trees.index(target_tree)
      left_pos = 0
      i.times do |index|
        left_pos += forest_trees[index]
      end
      left_pos..(left_pos + target_tree - 1)
    end

    # Get leaf tree height at pos.
    # @param [Integer] pos leaf position.
    # @return [Integer] tree height.
    def tree_height(pos)
      r = 0..0
      tree_heights = acc.map.with_index{|a, i| a ? i : nil}.reverse
      tree_heights[tree_heights.index(highest_height - 1)..-1].each do |h|
        next unless h
        r = (r.last...(r.last + 2**h))
        return h if r.include?(pos)
      end
    end

    # Switch one leaf and remove leaf in the forest.
    # @param [Utreexo::Proof] proof proof of removed leaf
    # @param [String] s currently being processed
    def switch_single_leaf(proof, s)
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
          target = Utreexo.parent(target, s)
          new_target = Utreexo.parent(new_target, s)
        else
          target = Utreexo.parent(s, target)
          new_target = Utreexo.parent(s, new_target)
        end
        proofs.select{|p|p.siblings.include?(target)}.each do |p|
          p.siblings[p.siblings.index(target)] = new_target
        end
      end
    end

    # Switch leaf blocks to be removed in the forest.
    # @param [Utreexo::Proof] proof proof of removed leaf
    # @param [Integer] fl leaves count in the forest.
    # @param [Integer] h the height currently being processed
    def switch_leaf_block(proof, fl, h)
      switch_size = 2 ** h
      sw_to_range = target_tree_range(fl, switch_size)
      sw_to = sw_to_range.map {|pos|proofs.find{|p|p.position == pos}}
      sw_from_range = proof.switch_range(switch_size)
      sw_from = {}
      sw_from_range.each {|pos|sw_from[pos] = proofs.find{|p|p.position == pos}}
      height = proof.tree_height
      # sort from tree
      sorted_from = sw_from.sort{|(k1, v1), (k2, v2)| proof.same_subtree_height(k2) <=> proof.same_subtree_height(k1)}

      sw_from_range.each.with_index do |pos, i|
        from = sorted_from[i][1]
        to = sw_to[i]
        if from
          from.position = sw_to_range.first + i unless proof == from
          from.siblings.clear if from.payload == proof.siblings[0] # proof's sibling
        end
        if to
          to.position = sw_from_range.first + i
          to.siblings = to.siblings.slice(0, h) + proof.siblings.slice(-(height - h), height - h)
        end
      end

      # Update another branch's siblings in the same tree as the proof
      updated_parents = proof.switched_parents(acc[h], h)
      # right branch
      branch = (sw_from_range.last + 1)..(proof.tree_leaves - 1)
      branch.each do |pos|
        p = find_proof_at(pos)
        next unless p
        sub_h = proof.same_subtree_height(pos) - 1
        p.siblings = p.siblings.slice(0, sub_h)
        (height - sub_h).times do |i|
          target = acc[p.siblings.size]
          target = i.even? ? updated_parents[i] : proof.siblings[p.siblings.size] unless target
          p.siblings << target
        end
      end
      # left branch
      branch = 0..(sw_from_range.first - 1)
      branch.each do |pos|
        p = find_proof_at(pos)
        next unless p
        branch_height = Math.log2(branch.size).to_i
        p.siblings = p.siblings.slice(0, branch_height)
        (height - branch_height).times do
          p.siblings << (acc[p.siblings.size] ? acc[p.siblings.size] : proof.siblings[p.siblings.size])
        end
      end
    end

  end
end