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

      f.add('a00100aa00000000000000000000000000000000000000000000000000000000')
      expect(f.num_leaves).to eq(2)
      expect(f.acc[1]). to eq('736b3e12120637186a0a8eef8ce45ed69b39119182cc749b793f05de3996f464')
      expect(f.acc[0]). to be nil

      f.add('a00200aa00000000000000000000000000000000000000000000000000000000')
      expect(f.num_leaves).to eq(3)
      expect(f.acc[1]). to eq('736b3e12120637186a0a8eef8ce45ed69b39119182cc749b793f05de3996f464')
      expect(f.acc[0]).to eq('a00200aa00000000000000000000000000000000000000000000000000000000')

      f.add('a00300aa00000000000000000000000000000000000000000000000000000000')
      expect(f.num_leaves).to eq(4)
      expect(f.acc[2]). to eq('2d043522d1fc5adfa966a889492acc8b4f924869e18192ad6f4bcb30db6d56c0')
      expect(f.acc[1]). to be nil
      expect(f.acc[0]).to be nil
    end
  end

end