require_relative '../../model/puppet_class'

PuppetLint.new_check(:class_parameter) do
  @fixed = false

  def check
    class_indexes.each do |class_index|
      puppet_class = PuppetClass.new(tokens, class_index)

      next unless puppet_class.parameter_list

      unless puppet_class.parameter_list.validate
        puppet_class.parameter_list.errors.each { |error| notify :error, error }
      end
    end
  end

  def fix(problem)
    return if @fixed

    resorted_tokens = []
    token_index = 0

    class_indexes.each do |class_index|
      puppet_class = PuppetClass.new(tokens, class_index)

      if puppet_class.has_parameter_documentation?
        resorted_tokens += tokens[token_index...puppet_class.parameter_documentation_start_index]
        puppet_class.sorted_parameter_documentation_list.each do |parameter_documentation|
          resorted_tokens += parameter_documentation.tokens
        end
        resorted_tokens += tokens[puppet_class.parameter_documentation_end_index..puppet_class.parameter_list.start_index]
      else
        resorted_tokens += tokens[token_index..puppet_class.parameter_list.start_index]
      end

      sorted_class_parameter_list = puppet_class.sorted_parameter_list
      sorted_class_parameter_list.each do |parameter|
        resorted_tokens += parameter.tokens

        unless parameter == sorted_class_parameter_list.last
          resorted_tokens << PuppetLint::Lexer::Token.new(:COMMA, ",", 0,0)
        end

        resorted_tokens << PuppetLint::Lexer::Token.new(:NEWLINE, "\n", 0,0) unless parameter == sorted_class_parameter_list.last
      end

      token_index = puppet_class.parameter_list.end_index
    end

    resorted_tokens += tokens[token_index..-1]
    tokens.replace(resorted_tokens)

    @fixed = true
  end
end
