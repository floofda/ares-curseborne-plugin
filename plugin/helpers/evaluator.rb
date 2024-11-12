module AresMUSH
  module CoD
    # adapted from https://codereview.stackexchange.com/questions/119530/codewars-mathematical-expresion-evaluator
    # parse the initial expression, break it up into an array
    # detects negation and cheges the symbol from '-' to '!'
    def self.tokenize_expression(expression)
      s = expression.to_s.gsub(/\B\s+|\s+\B/, '')
        .gsub(/(?<![\w\d\)])-/, '!')
        .gsub(/[ -]/, '_')

      tokens = s.split(/(\d+\.\d+|\d+)|([\|&\+\-\*\/\(\)>=<\?])|([\w_:\.]+)/) || []
      tokens.select {|t| t != ''}
    end


    # take the array and make sub arrays based on the parentheses
    # e.g. ['(', '1', '+', '(', '2', '+', '3', ')', ')'] -> ['1', '+', ['2', '+', '3']]
    def self.nest_parens(tokens)
      stack = []
      result = tokens.reduce([]) do |res, token|
        case token
          when '(' then stack.push(res); []
          when ')' then stack.pop << res
          else res << token
        end
      end
      throw "Unclosed parenthesis" if not stack.empty?
      result
    end

    # find all the neagtions and convert them to nested postfix
    # e.g. '5-n6' becomes '5-[n 6]'
    def self.postfix_negation(tokens)
      return tokens if not tokens.is_a? Array
      tokens = tokens.map{ |t| postfix_negation(t) }

      result = []
      while first = tokens.shift
        if first == '!'
          result << [first, tokens.shift]
        else
          result << first
        end
      end
      result
    end

    # find all operations (mult/div or plus/minus) and convert to nested postfix
    # e.g. '1+2*3' becomes '[+ 1 [* 2 3]]'
    def self.postfix_ops(tokens, ops=['/','*'])
      return tokens if not tokens.is_a? Array
      tokens = tokens.map{ |t| postfix_ops(t, ops) }

      result = []
      while first = tokens.shift
        if ops.include?(tokens.first)
          second, third = tokens.shift(2)
          tokens.unshift([ second, first, third ])
        else
          result << first
        end
      end
      result
    end

    def self.standardize str
      (str || '').gsub(/[ -]/, '_')
    end

    def self.substitute key, keyring
      return key.to_i if is_numeric? key
      return key if !key.is_a? String
      type, stat, value = key.split(':')
      value = value ? value.to_i : 1

      check = ((get_rating(keyring, stat) || -1) >= value.to_i)
      check.nil? ? key : check
    end

    # coerce string to boolean for evaluation
    def self.to_b(e)
      e.to_s.downcase.strip == 'true' ? true : false
    end

    # take a fully processed, postfix tree and recursively evaluate the expressions
    def self.evaluate(tree, keyring)
      return tree if !tree.is_a? Array
      tree = tree.map {|n| evaluate(n, keyring) }
      return substitute(tree.first, keyring) if tree.length == 1
      first, second, third = tree

      second = substitute(second, keyring)
      third = substitute(third, keyring)

      case first
        when '!"' then -second
        when '+' then second + third
        when '-' then second - third
        when '*' then second * third
        when '/' then second / third
        when '=' then second == third
        when '<' then second < third
        when '>' then second > third
        when '|' then to_b(second) || to_b(third)
        when '&' then to_b(second) && to_b(third)
        else raise "Unkown Op: #{first}"
      end
    end

    # alias for evaluate
    def self.pass_lock(expression, keyring = nil)
      return parse_expression(expression, keyring)
    end

    # wrapper to call all the needed steps for processing
    def self.parse_expression(expression, keyring = nil)
      return true if expression.nil?
      tokens = tokenize_expression(expression)
      tokens = nest_parens(tokens)
      tokens = postfix_negation(tokens)
      tokens = postfix_ops(tokens, ['/','*'])
      tokens = postfix_ops(tokens, ['+','-'])
      tokens = postfix_ops(tokens, ['<', '>', '='])
      tokens = postfix_ops(tokens, ['|', '&'])
      evaluate(tokens, keyring)
    end
  end
end
