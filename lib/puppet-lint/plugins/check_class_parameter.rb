require_relative '../../model/class_parameter_list'

PuppetLint.new_check(:class_parameter) do
  def check
    class_indexes.each do |class_index|
      next if class_index[:param_tokens].nil?

      params = []
      optional_params = []

      class_index[:param_tokens].each do |param_token|
        next unless param_token.type == :VARIABLE && param_token.prev_code_token.type != :EQUALS

        if param_token.next_code_token.nil? || param_token.next_code_token.type != :EQUALS
          notify :error, {
            :message => "Required parameter #{param_token.value} should be specified before optional parameters",
            :line    => param_token.line,
            :column  => param_token.column
          } if optional_params.any?

          params.push(param_token)
        elsif param_token.next_code_token && param_token.next_code_token.type == :EQUALS
          optional_params.push(param_token)
        end
      end

      check_alphabetical_order(params)
      check_alphabetical_order(optional_params)
    end
  end

  def check_alphabetical_order(params)
    parameter_names = params.map(&:value)

    if parameter_names != parameter_names.sort
      notify :error, {
        :message => "Parameter list not in alphabetical order",
        :line    => params.first.line,
        :column  => params.first.column
      }
    end
  end

  def fix(problem)
    resorted_tokens = []
    token_index = 0

    class_parameter_lists.each do |class_parameter_list|
      resorted_tokens += tokens[token_index..class_parameter_list.start_index]

      class_parameter_list.sort.each do |parameter|
        resorted_tokens += parameter.tokens
      end

      token_index = class_parameter_list.end_index
    end

    resorted_tokens += tokens[token_index..-1]
    tokens.replace(resorted_tokens)
  end

  private
  def class_parameter_lists
    lists = []

    class_indexes.each do |class_index|
      param_tokens = class_index[:param_tokens]
      next if param_tokens.nil?

      lists << ClassParameterList.new(param_tokens, tokens.index(param_tokens.first), tokens.index(param_tokens.last))
    end

    lists
  end
end
