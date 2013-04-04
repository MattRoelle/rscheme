require 'babel_bridge'

$built_in_procs = {
  
  '+' => proc { |args|
    result = 0
    args.each do  |arg|
      result += arg.to_s.to_f
    end
    result
  },
  
  '-' => proc { |args|
    result = args.first.to_s.to_f
    args[1..args.length].each do |arg|
      result -= arg.to_s.to_f
    end
    result
  },
  
  '*' => proc { |args|
    result = args.first.to_s.to_f
    args[1..args.length].each do |arg|
      result *= arg.to_s.to_f
    end
    result
  },
  
  '/' => proc { |args|
    result = args.first.to_s.to_f
    args[1..args.length].each do |arg|
      result /= arg.to_s.to_f
    end
    result
  },
  
  'print' => proc { |args|
    print args.first.to_s
  }

}

$built_in_macros = {

}

class Parser < BabelBridge::Parser

  rule :expression, '\'(', many(:expression, ' '), ')' do
    def evaluate
      ret = []
      expression.each do |e|
        ret << e.to_s        
      end
      ret
    end
  end

  rule :expression, '\'', :expression do
    def evaluate
      expression.to_s
    end
  end

  rule :expression, '(', many(:expression, ' '), ')' do
    def evaluate
      proc_name = expression[0].to_s
      proc_args = expression[1..expression.length]
      newArgs = []
      proc_args.each do |arg|
        newArgs << arg.evaluate
      end
      $built_in_procs[proc_name].call(newArgs)
      end
  end

  rule :expression, '(', many(:identifier, ' '), ')' do
    def evaluate
      proc_name = identifier[0].to_s
      proc_args = identifier[1..expression.length]
      return $built_in_procs[proc_name].call(proc_args)
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
