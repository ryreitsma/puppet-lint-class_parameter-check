require_relative 'parameter_list'

class PuppetClass
  def initialize(tokens, index)
    @tokens, @index = tokens, index
  end

  def name
    @name ||= @index[:tokens].select do |token|
      token.type == :NAME
    end.first.value
  end

  def parameter_list
    param_tokens = @index[:param_tokens]
    return if param_tokens.nil?

    @parameter_list ||= ParameterList.new(param_tokens, @tokens.index(param_tokens.first), @tokens.index(param_tokens.last))
  end
end
