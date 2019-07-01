require "utreexo/version"
require 'digest/sha2'
require 'blake2b'

module Utreexo
  class Error < StandardError; end

  autoload :Forest, 'utreexo/forest'
  autoload :Proof, 'utreexo/proof'

  module_function

  # Calculate parent hash
  # @param [String] left left node hash with hex format.
  # @param [String] right left node hash with hex format.
  # @return [String] a parent hash with hex format.
  def parent(left, right)
    Blake2b.hex([left + right].pack('H*'))
  end

end
