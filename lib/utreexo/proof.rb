module Utreexo
  class Proof

    attr_reader :right # where at the bottom of the tree it sits
    attr_reader :payload  # hash of the thing itself (what's getting proved)
    attr_reader :siblings # hash of siblings up to a root

    def initialize(right, payload, siblings = [])
      @right = right
      @payload = payload
      @siblings = siblings
    end

    def right?
      right
    end

    def left?
      !right
    end

  end
end