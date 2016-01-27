PuppetLint.new_check(:class_parameter) do
  def check
    class_indexes.each do |class_index|
      next if class_index[:param_tokens].nil?

      params = []
      optional_params = []

      class_index[:param_tokens].each do |parameter_token|
        next unless parameter_token.type == :VARIABLE

        if parameter_token.next_code_token.nil? || parameter_token.next_code_token.type != :EQUALS
          notify :error, {
            :message => "Required parameters should be specified before optional parameters",
            :line    => parameter_token.line,
            :column  => parameter_token.column
          } if optional_params.any?

          params.push(parameter_token)
        elsif parameter_token.next_code_token && parameter_token.next_code_token.type == :EQUALS
          optional_params.push(parameter_token)
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
        :message => "Parameters not in alphabetical order",
        :line    => params.first.line,
        :column  => params.first.column
      }
    end
  end
end
