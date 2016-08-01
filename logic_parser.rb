require 'minitest/autorun'
require 'logger'

# Project: simple logic and math parser
# Missing: evaluation, code clean (specially the huge case) and AST generation

# Implements the hunting-yard algorithm
module LogicExp
  module Simple
    OPERATORS   = /(\*|\+|\/|\-|\^)/
    VARIABLE    = /[a-z0-9]/
    PRECEDANCE  = {
      '+' => 2,
      '-' => 2,
      '/' => 3,
      '*' => 3
    }

    # Easy peasy: one char tokens
    def self.tok(string)
      string.
        split(//).
        reject { |c| c.strip.empty? }
    end

    def self.parse(tokens, logger: Logger.new(STDOUT))
      output = []
      stack = []
      until tokens.empty?
        token = tokens.shift
        logger.debug "=> current token:`#{token}` read"
        case token
        when VARIABLE
          logger.debug 'processing variable'
          output << token
        when OPERATORS
          logger.debug 'processing operator'

          while ((peek = stack.last) =~ OPERATORS) do
            if PRECEDANCE[token] >= PRECEDANCE[peek]
              output << stack.pop
            end
          end

          stack << token
        when '('
          logger.debug 'processing left parenthesis'
          stack << token
        when ')'
          logger.debug 'processing right parenthesis'
          found_left = false
          while top = stack.pop do
            if top == '('
              # nop
              found_left = true
              break
            else
              output << top
            end
          end
          unless found_left
            raise SyntaxError
          end
        end
      end

      while top = stack.pop
        if top == '(' || top == ')'
          raise SyntaxError
        else
          output << top
        end
      end

      output
    end
  end
end

input = '3+4+5+9'
puts LogicExp::Simple.parse(LogicExp::Simple.tok(input)).inspect

class LogicExpTest < Minitest::Test
  def test_super_simple
    tokens = LogicExp::Simple.tok('a')

    assert_equal %w(a), tokens
    assert_equal %w(a), LogicExp::Simple.parse(tokens)
  end

  def test_simple_expression
    tokens = LogicExp::Simple.tok('a + b')

    assert_equal %w(a + b), tokens
    assert_equal %w(a b +), LogicExp::Simple.parse(tokens)
  end

  def test_more_complex_expression
    tokens = LogicExp::Simple.tok('a + (b+c)')

    assert_equal %w(a + ( b + c )), tokens
    assert_equal %w(a b c + +), LogicExp::Simple.parse(tokens)
  end

  def test_precedance
    tokens = LogicExp::Simple.tok('a*(b+c)')

    assert_equal %w(a * ( b + c )), tokens
    assert_equal %w(a b c + *), LogicExp::Simple.parse(tokens)
  end

  def test_handles_well_multiple_spaces
    tokens = LogicExp::Simple.tok('a +    ( b      *c)')

    assert_equal %w(a + ( b * c )), tokens
    assert_equal %w(a b c * +), LogicExp::Simple.parse(tokens)
  end
end
