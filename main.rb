require 'babel_bridge'

$builtInProcs = {
  "+" => Proc.new { |args|
    result = 0
    args.each do  |arg|
      result += arg.to_s.to_f
    end
    result
  },
  "-" => Proc.new { |args|
    result = args.first.to_s.to_f
    args[1..args.length].each do |arg|
      result -= arg.to_s.to_f
    end
    result
  },
  "*" => Proc.new { |args|
    result = args.first.to_s.to_f
    args[1..args.length].each do |arg|
      result *= arg.to_s.to_f
    end
    result
  },
  "/" => Proc.new { |args|
    result = args.first.to_s.to_f
    args[1..args.length].each do |arg|
      result /= arg.to_s.to_f
    end
    result
  }
}

class Parser < BabelBridge::Parser

  rule :expression, "(", many(:expression, " "), ")" do
    def evaluate
      procName = expression[0].to_s
      procArgs = expression[1..expression.length]
      newArgs = []
      procArgs.each do |arg|
        newArgs << arg.evaluate
      end
      $builtInProcs[procName].call(newArgs)
      end
  end
  rule :expression, "(", many(:identifier, " "), ")" do
    def evaluate
      procName = identifier[0].to_s
      procArgs = identifier[1..expression.length]
      return $builtInProcs[procName].call(procArgs)
    end
  end
  rule :expression, :identifier do
    def evaluate
      identifier.evaluate
    end
  end
  rule :identifier, /[a-zA-Z_0-9\+\-\*\/]*/ do
    def evaluate
      to_s
    end
  end

end

BabelBridge::Shell.new(Parser.new).start
