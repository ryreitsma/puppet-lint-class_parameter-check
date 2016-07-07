class Parameter
  class SyntaxError < StandardError; end
  attr_accessor :documentation

  def initialize
    @tokens = []
  end

  def is_optional?
    @tokens.any? { |token| token.type == :EQUALS }
  end

  def is_required?
    !is_optional?
  end

  def name
    @tokens.select do |token|
      token.type == :VARIABLE
    end.first.value
  end

  def add(token)
    # A parameter never starts with a newline token, so skip that one
    return if @tokens.empty? && token.type == :NEWLINE
    # Raise a syntax error if the parameter starts with a comma.
    raise SyntaxError, "Syntax error: Expected a parameter definition, found comma on line #{token.line}, column #{token.column}" if @tokens.empty? && token.type == :COMMA

    @tokens << token
  end

  def tokens
    strip_newlines(@tokens)
  end

  def line
    @tokens.first.line
  end

  def column
    @tokens.first.column
  end

  def <=>(other)
    if (self.is_optional? && other.is_optional?) || (self.is_required? && other.is_required?)
      return self.name <=> other.name
    elsif self.is_optional? && other.is_required?
      return 1
    else
      return -1
    end
  end

  private
  def strip_newlines(tokens)
    stripped_tokens = strip_starting_newlines(tokens)
    strip_ending_newlines(stripped_tokens)
  end

  def strip_starting_newlines(tokens)
    tokens.inject([]) do |memo, token|
      unless memo.empty? && token.type == :NEWLINE
        memo << token
      end
      memo
    end
  end

  def strip_ending_newlines(tokens)
    strip_starting_newlines(tokens.reverse).reverse
  end
end
