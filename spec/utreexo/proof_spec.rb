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

      f = create_forest(14)
      e8 = f.proof('a00800aa00000000000000000000000000000000000000000000000000000000')
      expect(e8.tree_height).to eq(2)
      ec = f.proof('a00c00aa00000000000000000000000000000000000000000000000000000000')
      expect(ec.tree_height).to eq(1)

      f = create_forest(3)
      e2 = f.proof('a00200aa00000000000000000000000000000000000000000000000000000000')
      expect(e2.tree_height).to eq(0)
    end
  end

end