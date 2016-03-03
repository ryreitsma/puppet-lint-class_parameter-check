require_relative '../../model/puppet_class'

PuppetLint.new_check(:class_parameter) do
  def check
    class_indexes.each do |class_index|
      puppet_class = PuppetClass.new(tokens, class_index)

      unless puppet_class.parameter_list.validate
        puppet_class.parameter_list.errors.each { |error| notify :error, error }
      end
    end
  end

  def fix(problem)
    resorted_tokens = []
    token_index = 0

    class_indexes.each do |class_index|
      puppet_class = PuppetClass.new(tokens, class_index)

      resorted_tokens += tokens[token_index..puppet_class.parameter_list.start_index]

      sorted_class_parameter_list = puppet_class.parameter_list.sort
      sorted_class_parameter_list.each do |parameter|
        resorted_tokens += parameter.tokens

        unless parameter == sorted_class_parameter_list.last
          resorted_tokens << PuppetLint::Lexer::Token.new(:COMMA, ",", 0,0)
        end

        resorted_tokens << PuppetLint::Lexer::Token.new(:NEWLINE, "\n", 0,0)
      end

      token_index = puppet_class.parameter_list.end_index
    end

    resorted_tokens += tokens[token_index..-1]
    tokens.replace(resorted_tokens)
  end
end
