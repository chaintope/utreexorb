module Utreexo
  class Proof

    attr_reader :right # where at the bottom of the tree it sits
    attr_reader :payload  # hash of the thing itself (what's getting proved)
    attr_reader :siblings # hash of siblings up to a root

    # initialize
    # @param [Boolean] right Whether the element is a node on the right
    # @param [String] payload Target element
    # @param [Array[String]] siblings proofs
    def initialize(right, payload, siblings = [])
      @right = right
      @payload = payload
      @siblings = siblings
    end

    # Whether the element is a node on the right
    # @return [Boolean]
    def right?
      right
    end

    # Whether the element is a node on the left
    # @return [Boolean]
    def left?
      !right
    end

  end
end