class ClassParameter
  attr_reader :tokens

  def initialize
    @tokens = []
  end

  def is_optional?
    tokens.any? { |token| token.type == :EQUALS }
  end

  def is_required?
    !is_optional?
  end

  def name
    tokens.select do |token|
      token.type == :VARIABLE
    end.first.value
  end

  def add(token)
    tokens << token
  end

  def line
    tokens.first.line
  end

  def column
    tokens.first.column
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
end
