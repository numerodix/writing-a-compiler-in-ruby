
module AST

  # Adds properties to AST nodes that simplify error
  # reporting, debugging etc.
  module Node
    attr_accessor :position
  end

  # Inheriting from Array lets most code just work on the
  # expression as a raw set of data. And it avoids the hassle
  # of changing lots of code. At the same time, we can attach
  # extra data - we're sneaky like that.
  #
  # call-seq:
  #   Expr[1,2,3]
  #
  # FIXME: When called with tokens from the scanner, it is the
  # intention that these tokens will *also* hav a position
  # and carry position information, and that Expr's constructor
  # will default to take the position information of the first
  # node it is passed that respond_to?(:position).
  #
  # Alternatively, if the first argument is_a?(Scanner::Position)
  # it will be stripped and used as the position.
  class Expr < Array
    include Node

    def self.[] *args
      if args.size > 0 && args.first.is_a?(Scanner::Position)
        pos = args.shift
      end
      e = super *args
      sub = e.find {|n| n.respond_to?(:position) }
      e.position = sub.position if sub
      e.position = pos if pos
      e
    end
  end

  # For convience
  E = Expr
end
