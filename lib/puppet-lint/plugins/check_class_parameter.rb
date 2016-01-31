require_relative '../../model/class_parameter_list'

PuppetLint.new_check(:class_parameter) do
  def check
    class_parameter_lists.each do |class_parameter_list|
      class_parameter_list.validate

      class_parameter_list.errors.each { |error| notify :error, error }
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
