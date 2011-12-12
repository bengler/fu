module Fu
  # An exception raised by Fu code.
  class Error < StandardError
    # The line of the template on which the error occurred.
    #
    # @return [Fixnum]
    attr_reader :position

    # @param message [String] The error message
    # @param line [Fixnum] See \{#line}
    def initialize(message = nil, position = nil)
      super(message)
      @position = position
    end
  end

  # SyntaxError is the type of exception raised when Fu encounters an
  # ill-formatted document.
  class SyntaxError < Fu::Error; end
end
