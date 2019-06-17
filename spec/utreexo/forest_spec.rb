require 'spec_helper'

RSpec.describe Utreexo::Forest do

  describe '#add' do
    it 'should be return updated forest' do
      f = Utreexo::Forest.new
      expect(f.num_leaves).to eq(0)
      expect(f.height).to eq(0)

      f.add('a00000aa00000000000000000000000000000000000000000000000000000000')
      expect(f.num_leaves).to eq(1)
      expect(f.acc[0]).to eq('a00000aa00000000000000000000000000000000000000000000000000000000')
      expect(f.height).to eq(1)

      f.add('a00100aa00000000000000000000000000000000000000000000000000000000')
      expect(f.num_leaves).to eq(2)
      expect(f.acc[1]). to eq('736b3e12120637186a0a8eef8ce45ed69b39119182cc749b793f05de3996f464')
      expect(f.acc[0]). to be nil
      expect(f.height).to eq(2)

      f.add('a00200aa00000000000000000000000000000000000000000000000000000000')
      expect(f.num_leaves).to eq(3)
      expect(f.acc[1]). to eq('736b3e12120637186a0a8eef8ce45ed69b39119182cc749b793f05de3996f464')
      expect(f.acc[0]).to eq('a00200aa00000000000000000000000000000000000000000000000000000000')
      expect(f.height).to eq(2)

      f.add('a00300aa00000000000000000000000000000000000000000000000000000000')
      expect(f.num_leaves).to eq(4)
      expect(f.acc[2]). to eq('2d043522d1fc5adfa966a889492acc8b4f924869e18192ad6f4bcb30db6d56c0')
      expect(f.acc[1]). to be nil
      expect(f.acc[0]).to be nil
      expect(f.height).to eq(3)
    end
  end

  describe '#remove' do
    subject {
      f = Utreexo::Forest.new
      f.add('a00000aa00000000000000000000000000000000000000000000000000000000')
      f.add('a00100aa00000000000000000000000000000000000000000000000000000000')
      f.add('a00200aa00000000000000000000000000000000000000000000000000000000')
      f.add('a00300aa00000000000000000000000000000000000000000000000000000000')
      f.add('a00400aa00000000000000000000000000000000000000000000000000000000')
      f
    }
    context 'remove last elements' do
      it 'should remove element from forest' do
        expect(subject.acc[0]).to eq('a00400aa00000000000000000000000000000000000000000000000000000000')
        expect(subject.acc[1]).to be nil
        expect(subject.acc[2]).to eq('2d043522d1fc5adfa966a889492acc8b4f924869e18192ad6f4bcb30db6d56c0')

        # remove last elements
        proof = Utreexo::Proof.new(4, 'a00400aa00000000000000000000000000000000000000000000000000000000', [])
        subject.remove(proof)
        expect(subject.acc[0]).to be nil
        expect(subject.acc[1]).to be nil
        expect(subject.acc[2]).to eq('2d043522d1fc5adfa966a889492acc8b4f924869e18192ad6f4bcb30db6d56c0')
      end
    end

    context 'remove 3rd element' do
      it 'should remove element from forest' do
        proof = Utreexo::Proof.new(2, 'a00200aa00000000000000000000000000000000000000000000000000000000',
                          ['a00300aa00000000000000000000000000000000000000000000000000000000', '736b3e12120637186a0a8eef8ce45ed69b39119182cc749b793f05de3996f464'])
        subject.remove(proof)
        expect(subject.acc[2]).to eq('5fd725b67d4651a8d5153bfea9242322f2d96f152ba3cf9cbce2a7ba694ca0e6')
      end
    end

    context 'remove 4th element' do
      it 'should remove element from forest' do
        proof = Utreexo::Proof.new(3, 'a00300aa00000000000000000000000000000000000000000000000000000000',
                                   ['a00200aa00000000000000000000000000000000000000000000000000000000', '736b3e12120637186a0a8eef8ce45ed69b39119182cc749b793f05de3996f464'])
        subject.remove(proof)
        expect(subject.acc[2]).to eq('09a7e3a294b33a5e38086fd9859d698f9082c78481cf39d52eceefc3839b06cc')
      end
    end

    context 'remove with invalid proof' do
      it 'should raise error' do
        proof = Utreexo::Proof.new(0, 'a00300aa00000000000000000000000000000000000000000000000000000000',
                                   ['a00200aa00000000000000000000000000000000000000000000000000000000', '736b3e12120637186a0a8eef8ce45ed69b39119182cc749b793f05de3996f464'])
        expect{subject.remove(proof)}.to raise_error(Utreexo::Error, 'The target element does not exist in the forest.')
      end
    end

  end

  describe '#include' do
    subject {
      f = Utreexo::Forest.new
      f.add('a00000aa00000000000000000000000000000000000000000000000000000000')
      f.add('a00100aa00000000000000000000000000000000000000000000000000000000')
      f.add('a00200aa00000000000000000000000000000000000000000000000000000000')
      f.add('a00300aa00000000000000000000000000000000000000000000000000000000')
      f.add('a00400aa00000000000000000000000000000000000000000000000000000000')
      f
    }
    context 'element is root' do
      it 'should return true' do
        proof = Utreexo::Proof.new(4, 'a00400aa00000000000000000000000000000000000000000000000000000000')
        expect(subject.include?(proof)).to be true
      end
    end

    context 'element is not root' do
      it 'should return true' do
        proof = Utreexo::Proof.new(0, 'a00000aa00000000000000000000000000000000000000000000000000000000',
                                   ['a00100aa00000000000000000000000000000000000000000000000000000000', '1a8eb723d8f9067dfb4fee12c723d2a772ffe05b6558186661dc0874061734dd'])
        expect(subject.include?(proof)).to be true

        proof = Utreexo::Proof.new(1, 'a00100aa00000000000000000000000000000000000000000000000000000000',
                                   ['a00000aa00000000000000000000000000000000000000000000000000000000', '1a8eb723d8f9067dfb4fee12c723d2a772ffe05b6558186661dc0874061734dd'])
        expect(subject.include?(proof)).to be true

        proof = Utreexo::Proof.new(2, 'a00200aa00000000000000000000000000000000000000000000000000000000',
                                   ['a00300aa00000000000000000000000000000000000000000000000000000000', '736b3e12120637186a0a8eef8ce45ed69b39119182cc749b793f05de3996f464'])
        expect(subject.include?(proof)).to be true

        proof = Utreexo::Proof.new(3, 'a00300aa00000000000000000000000000000000000000000000000000000000',
                                   ['a00200aa00000000000000000000000000000000000000000000000000000000', '736b3e12120637186a0a8eef8ce45ed69b39119182cc749b793f05de3996f464'])
        expect(subject.include?(proof)).to be true
      end
    end

    context 'nonexistent element' do
      it 'should return false' do
        proof = Utreexo::Proof.new(3, 'a00200aa00000000000000000000000000000000000000000000000000000000',
                                   ['a00400aa00000000000000000000000000000000000000000000000000000000', '736b3e12120637186a0a8eef8ce45ed69b39119182cc749b793f05de3996f464'])
        expect(subject.include?(proof)).to be false

        proof = Utreexo::Proof.new(3, 'a00200aa00000000000000000000000000000000000000000000000000000000',
                                   ['a00300aa00000000000000000000000000000000000000000000000000000000', '136b3e12120637186a0a8eef8ce45ed69b39119182cc749b793f05de3996f464'])
        expect(subject.include?(proof)).to be false

        proof = Utreexo::Proof.new(3, 'a00200aa00000000000000000000000000000000000000000000000000000000',
                                   ['a00300aa00000000000000000000000000000000000000000000000000000000'])
        expect(subject.include?(proof)).to be false

        proof = Utreexo::Proof.new(3, 'a00200aa00000000000000000000000000000000000000000000000000000000')
        expect(subject.include?(proof)).to be false
      end
    end
  end

  describe 'tracking proof' do
    it 'should provide latest proof' do
      f = Utreexo::Forest.new
      expect(f.proofs).to be_empty

      f.add('a00000aa00000000000000000000000000000000000000000000000000000000', true)
      proof0 = f.proofs[0]
      expect(proof0.payload).to eq('a00000aa00000000000000000000000000000000000000000000000000000000')
      expect(proof0.position).to eq(0)
      expect(proof0.siblings).to be_empty

      f.add('a00100aa00000000000000000000000000000000000000000000000000000000', true)
      expect(proof0.position).to eq(0)
      expect(proof0.siblings).to eq(['a00100aa00000000000000000000000000000000000000000000000000000000'])
      proof1 = f.proofs[1]
      expect(proof1.payload).to eq('a00100aa00000000000000000000000000000000000000000000000000000000')
      expect(proof1.position).to eq(1)
      expect(proof1.siblings).to eq(['a00000aa00000000000000000000000000000000000000000000000000000000'])

      f.add('a00200aa00000000000000000000000000000000000000000000000000000000', true)
      expect(proof0.position).to eq(0)
      expect(proof0.siblings).to eq(['a00100aa00000000000000000000000000000000000000000000000000000000'])
      expect(proof1.position).to eq(1)
      expect(proof1.siblings).to eq(['a00000aa00000000000000000000000000000000000000000000000000000000'])
      proof2 = f.proofs[2]
      expect(proof2.position).to eq(2)
      expect(proof2.siblings).to be_empty

      f.add('a00300aa00000000000000000000000000000000000000000000000000000000', true)
      expect(proof0.position).to eq(0)
      expect(proof0.siblings).to eq(['a00100aa00000000000000000000000000000000000000000000000000000000', '1a8eb723d8f9067dfb4fee12c723d2a772ffe05b6558186661dc0874061734dd'])
      expect(proof1.position).to eq(1)
      expect(proof1.siblings).to eq(['a00000aa00000000000000000000000000000000000000000000000000000000', '1a8eb723d8f9067dfb4fee12c723d2a772ffe05b6558186661dc0874061734dd'])
      expect(proof2.position).to eq(2)
      expect(proof2.siblings).to eq(['a00300aa00000000000000000000000000000000000000000000000000000000', '736b3e12120637186a0a8eef8ce45ed69b39119182cc749b793f05de3996f464'])
      proof3 = f.proofs[3]
      expect(proof3.position).to eq(3)
      expect(proof3.siblings).to eq(['a00200aa00000000000000000000000000000000000000000000000000000000', '736b3e12120637186a0a8eef8ce45ed69b39119182cc749b793f05de3996f464'])

      f.add('a00400aa00000000000000000000000000000000000000000000000000000000', true)
      proof4 = f.proofs[4]
      expect(proof4.position).to eq(4)
      expect(proof4.siblings).to be_empty

      f.add('a00500aa00000000000000000000000000000000000000000000000000000000')
      f.add('a00600aa00000000000000000000000000000000000000000000000000000000')
      f.add('a00700aa00000000000000000000000000000000000000000000000000000000', true)

      expect(proof0.siblings).to eq(['a00100aa00000000000000000000000000000000000000000000000000000000', '1a8eb723d8f9067dfb4fee12c723d2a772ffe05b6558186661dc0874061734dd', '7de8ac1fe747dac8bb66446a710bb05f302fb0cb0631aa292dcc28565d13f202'])
      expect(proof4.siblings).to eq(['a00500aa00000000000000000000000000000000000000000000000000000000', '81083b11ca29159545795d9b5cb32f6363fabd1c6a1571a975bcb5a88367416e', '2d043522d1fc5adfa966a889492acc8b4f924869e18192ad6f4bcb30db6d56c0'])

      proof7 = f.proofs[5]
      expect(proof7.position).to eq(7)
      expect(proof7.siblings).to eq(['a00600aa00000000000000000000000000000000000000000000000000000000', 'ec6ce61251d6f58e1e51d27c382dde5544603880ebd0e34a808dca14505df102', '2d043522d1fc5adfa966a889492acc8b4f924869e18192ad6f4bcb30db6d56c0'])
    end
  end

end