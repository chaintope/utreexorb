# Utreexorb [![Build Status](https://travis-ci.org/chaintope/utreexorb.svg?branch=master)](https://travis-ci.org/chaintope/utreexorb) [![Gem Version](https://badge.fury.io/rb/utreexo.svg)](https://badge.fury.io/rb/utreexo) [![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)

This library is a Ruby implementation of [Utreexo](https://github.com/mit-dci/utreexo/blob/master/utreexo.pdf).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'utreexo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install utreexo

## Usage

### Add element to forest.

```ruby
require 'utreexo'

# initialize forest.
f = Utreexo::Forest.new

# add element to forest.
f.add('a00000aa00000000000000000000000000000000000000000000000000000000')
f.add('a00100aa00000000000000000000000000000000000000000000000000000000')
# if you want to tracking proof, set tracking flag to true.
f.add('a00200aa00000000000000000000000000000000000000000000000000000000', true)
f.add('a00300aa00000000000000000000000000000000000000000000000000000000', true)
f.add('a00400aa00000000000000000000000000000000000000000000000000000000', true)

# forest has 2 tree, height 2, height 0
# accumulator root for height 2 tree
f.acc[2]
=> '2d043522d1fc5adfa966a889492acc8b4f924869e18192ad6f4bcb30db6d56c0'
# accumulator root for height 0 tree
f.acc[0]
=> 'a00400aa00000000000000000000000000000000000000000000000000000000'

# show forest.
puts f
07:2d04                         
|---------------\               |---------------\               
05:736b         06:1a8e         
|-------\       |-------\       |-------\       |-------\       
00:???? 01:???? 02:a002 03:a003 04:a004 
```

### Get proof

If leaf tracking enabled, you can get its proof. If you add or remove element to the forest, the position and inclusion proof of the leaf being tracked are updated.

```ruby
proof = f.proof('a00200aa00000000000000000000000000000000000000000000000000000000')
=> [2] leaf = a00200aa00000000000000000000000000000000000000000000000000000000, siblings = ["a00300aa00000000000000000000000000000000000000000000000000000000", "736b3e12120637186a0a8eef8ce45ed69b39119182cc749b793f05de3996f464"]

# get all tracking proofs
proofs = f.proofs
```

### Verify element.

```ruby
# proof for 3rd element
proof = f.proof('a00200aa00000000000000000000000000000000000000000000000000000000')

f.include?(proof)
=> true
```

### Remove element from forest.

```ruby
f.remove(proof)

# If delete 3rd element, last item move to 3rd element position, and root hash changed.
f.acc[2]
=> '5fd725b67d4651a8d5153bfea9242322f2d96f152ba3cf9cbce2a7ba694ca0e6' 
```
