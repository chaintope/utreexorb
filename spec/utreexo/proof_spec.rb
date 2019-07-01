require 'spec_helper'

RSpec.describe Utreexo::Proof do

  describe '#right' do
    it 'should handle position' do
      p = Utreexo::Proof.new(2, '')
      expect(p.right?).to be false
      expect(p.left?).to be true

      p = Utreexo::Proof.new(3, '')
      expect(p.right?).to be true
      expect(p.left?).to be false
    end
  end

  describe '#tree_height' do
    it 'should return tree height containing this element' do
      f = eight_forest
      e7 = f.proof('a00700aa00000000000000000000000000000000000000000000000000000000')
      expect(e7.tree_height).to eq(3)
      expect(e7.tree_leaves).to eq(8)

      f = create_forest(14)
      e8 = f.proof('a00800aa00000000000000000000000000000000000000000000000000000000')
      expect(e8.tree_height).to eq(2)
      expect(e8.tree_leaves).to eq(4)
      ec = f.proof('a00c00aa00000000000000000000000000000000000000000000000000000000')
      expect(ec.tree_height).to eq(1)
      expect(ec.tree_leaves).to eq(2)

      f = create_forest(3)
      e2 = f.proof('a00200aa00000000000000000000000000000000000000000000000000000000')
      expect(e2.tree_height).to eq(0)
      expect(e2.tree_leaves).to eq(1)
    end
  end

  describe '#same_tree_heigh' do
    it 'should return height' do
      f = create_forest(20)
      p = f.proof('a00400aa00000000000000000000000000000000000000000000000000000000')
      expect(p.same_subtree_height(4)).to eq(0)
      expect(p.same_subtree_height(5)).to eq(1)
      expect(p.same_subtree_height(6)).to eq(2)
      expect(p.same_subtree_height(3)).to eq(3)
      expect(p.same_subtree_height(0)).to eq(3)
      expect(p.same_subtree_height(8)).to eq(4)
      expect(p.same_subtree_height(15)).to eq(4)
      expect{p.same_subtree_height(16)}.to raise_error(Utreexo::Error)
      p = f.proof('a00000aa00000000000000000000000000000000000000000000000000000000')
      expect(p.same_subtree_height(1)).to eq(1)
      expect(p.same_subtree_height(2)).to eq(2)
      expect(p.same_subtree_height(4)).to eq(3)
      expect(p.same_subtree_height(15)).to eq(4)
      p = f.proof('a00e00aa00000000000000000000000000000000000000000000000000000000')
      expect(p.same_subtree_height(1)).to eq(4)
      expect(p.same_subtree_height(4)).to eq(4)
      expect(p.same_subtree_height(12)).to eq(2)
      expect(p.same_subtree_height(15)).to eq(1)
      expect(p.same_subtree_height(11)).to eq(3)
      expect{p.same_subtree_height(16)}.to raise_error(Utreexo::Error)
      p = f.proof('a00200aa00000000000000000000000000000000000000000000000000000000')
      expect(p.same_subtree_height(14)).to eq(4)

      f = create_forest(20)
      p = f.proof('a00200aa00000000000000000000000000000000000000000000000000000000')
      puts p.same_subtree_height(0)
      puts p.same_subtree_height(1)
      puts p.same_subtree_height(2)
      puts p.same_subtree_height(3)
      puts p.same_subtree_height(4)
      puts p.same_subtree_height(5)
      puts p.same_subtree_height(6)
      puts p.same_subtree_height(7)
    end
  end

end