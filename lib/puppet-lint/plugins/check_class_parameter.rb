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
end
