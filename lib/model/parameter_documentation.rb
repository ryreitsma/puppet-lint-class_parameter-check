class ParameterDocumentation
  attr_reader :tokens

  def initialize
    @tokens = []
  end

  def name
    @tokens.each do |token|
      if token.value.match(/@param (\w*)/)
        return $1
      end
    end
  end
end
