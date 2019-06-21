module Utreexo
  class Proof

    attr_accessor :position # where at the bottom of the tree it sits
    attr_reader :payload    # hash of the thing itself (what's getting proved)
    attr_accessor :siblings   # hash of siblings up to a root

    # initialize
    # @param [Integer] position Where at the bottom of the tree it sits
    # @param [String] payload Target element
    # @param [Array[String]] siblings proofs
    def initialize(position, payload, siblings = [])
      @position = position
      @payload = payload
      @siblings = siblings
    end

    # Whether the element is a node on the right
    # @return [Boolean]
    def right?
      position.odd?
    end

    # Whether the element is a node on the left
    # @return [Boolean]
    def left?
      position.even?
    end

    def to_s
      "[#{position}] leaf = #{payload}, siblings = #{siblings}"
    end

  end
end