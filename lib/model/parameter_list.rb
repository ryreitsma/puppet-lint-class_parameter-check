require_relative 'parameter'

class ParameterList
  attr_reader :errors, :start_index, :end_index

  def initialize(tokens, start_index, end_index)
    @tokens, @start_index, @end_index = tokens, start_index, end_index
    @errors = []
  end

  def sort
    parameters.sort
  end

  def each(&block)
    parameters.each do |parameter|
      yield parameter
    end
  end

  def optional_parameters
    parameters.select(&:is_optional?)
  end

  def required_parameters
    parameters.select(&:is_required?)
  end

  def validate
    optional_parameter_found = false

    parameters.each do |parameter|
      if parameter.is_required? && optional_parameter_found
        errors << {
          :message => "Required parameter #{parameter.name} should be specified before optional parameters",
          :line    => parameter.line,
          :column  => parameter.column
        }
      elsif parameter.is_optional?
        optional_parameter_found = true
      end
    end

    validate_alphabetical_order(required_parameters)
    validate_alphabetical_order(optional_parameters)

    errors.empty?
  end


  private
  def parameters
    parameter = Parameter.new
    stack = []

    @tokens.inject([]) do |memo, token|
      if [:LBRACK, :LPAREN].include?(token.type)
        stack.push(true)
      elsif [:RBRACK, :RPAREN].include?(token.type)
        stack.pop
      end

      if (token.type == :COMMA || token == @tokens.last) && stack.empty? && parameter.tokens.any?
        unless [:COMMA, :NEWLINE, :WHITESPACE, :INDENT].include?(token.type)
          parameter.add(token)
        end

        memo << parameter
        parameter = Parameter.new
      else
        parameter.add(token)
      end
      memo
    end
  end

  def validate_alphabetical_order(params)
    if params != params.sort
      errors << {
        :message => "Parameter list not in alphabetical order",
        :line    => params.first.line,
        :column  => params.first.column
      }
    end
  end
end
