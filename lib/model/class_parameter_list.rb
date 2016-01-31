require_relative 'class_parameter'

class ClassParameterList
  attr_reader :start_index, :end_index

  def initialize(tokens, start_index, end_index)
    @tokens, @start_index, @end_index = tokens, start_index, end_index
  end

  def sort
    parameters.sort
  end

  private
  def parameters
    parameter = ClassParameter.new

    @tokens.inject([]) do |memo, token|
      if token.type == :COMMA || token == @tokens.last
        # always add a comma and a newline token at the end of each parameter
        parameter.add(PuppetLint::Lexer::Token.new(:COMMA, ",", 0,0))
        parameter.add(PuppetLint::Lexer::Token.new(:NEWLINE, "\n", 0,0))
        memo << parameter
        parameter = ClassParameter.new
      elsif token.type != :NEWLINE
        parameter.add(token)
      end
      memo
    end
  end
end
