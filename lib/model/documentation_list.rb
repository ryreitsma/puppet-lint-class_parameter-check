require_relative 'parameter_documentation'

class DocumentationList
  attr_reader :start_index, :end_index

  def initialize(tokens, start_index, end_index)
    @tokens, @start_index, @end_index = tokens, start_index, end_index
  end

  def parameter_documentation_list
    return @parameter_documentation_list unless @parameter_documentation_list.nil?

    parameter_documentation = ParameterDocumentation.new
    harvest_tokens = false

    @parameter_documentation_list = @tokens.inject([]) do |memo, token|
      if token.type == :COMMENT && token.value.match(/@param \w*/)
        memo << parameter_documentation if parameter_documentation.tokens.any?
        parameter_documentation = ParameterDocumentation.new
        harvest_tokens = true
      end

      if (token.type == :COMMENT && token.value.strip == "")
        harvest_tokens = false
      end

      if harvest_tokens
        parameter_documentation.tokens << token
      end

      memo
    end

    @parameter_documentation_list << parameter_documentation if parameter_documentation.tokens.any?

    @parameter_documentation_list
  end
end
