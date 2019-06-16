require "utreexo/version"
require 'digest/sha2'
require 'blake2b'

module Utreexo
  class Error < StandardError; end

  autoload :Forest, 'utreexo/forest'
  autoload :Proof, 'utreexo/proof'

end
