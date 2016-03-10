require_relative 'parameter_list'
require_relative 'documentation_list'

class PuppetClass
  def initialize(tokens, index)
    @tokens, @index = tokens, index
  end

  def name
    @name ||= @index[:tokens].select do |token|
      token.type == :NAME
    end.first.value
  end

  def has_parameter_documentation?
    !parameter_documentation_list.empty?
  end

  def parameter_list
    param_tokens = @index[:param_tokens]
    return if param_tokens.nil?

    @parameter_list ||= ParameterList.new(param_tokens, @tokens.index(param_tokens.first), @tokens.index(param_tokens.last))
  end

  def documentation_list
    @documentation_list ||= DocumentationList.new(documentation_tokens, @tokens.index(documentation_tokens.first), @tokens.index(documentation_tokens.last))
  end

  def parameter_documentation_list
    documentation_list.parameter_documentation_list
  end

  def sorted_parameter_documentation_list
    sorted_parameter_list.inject([]) do |memo, parameter|
      documentation = parameter_documentation_list.select do |parameter_documentation|
        parameter_documentation.name == parameter.name
      end.first

      memo << documentation if documentation

      memo
    end
  end

  def sorted_parameter_list
    parameter_list.sort
  end

  def parameter_documentation_start_index
    @tokens.index(parameter_documentation_list.first.tokens.first)
  end

  def parameter_documentation_end_index
    @tokens.index(parameter_documentation_list.last.tokens.last) + 1
  end

  private
  def documentation_tokens
    return @doc_tokens unless @doc_tokens.nil? || @doc_tokens.empty?

    @doc_tokens = []
    prev_token = @index[:tokens].first.prev_token
    while (prev_token && prev_token.type != :RBRACE)
      @doc_tokens << prev_token

      prev_token = prev_token.prev_token
    end

    @doc_tokens.reverse!
    @doc_tokens
  end
end
