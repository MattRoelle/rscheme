require 'babel_bridge'

$built_in_procs = {
  
  '+' => proc { |args|
    result = 0
    args.each do  |arg|
      result += arg.to_f
    end
    result
  },
  
  '-' => proc { |args|
    result = args.first.to_s.to_f
    args[1..args.length].each do |arg|
      result -= arg.to_f
    end
    result
  },
  
  '*' => proc { |args|
    result = args.first.to_s.to_f
    args[1..args.length].each do |arg|
      result *= arg.to_f
    end
    result
  },
  
  '/' => proc { |args|
    result = args.first.to_s.to_f
    args[1..args.length].each do |arg|
      result /= arg.to_f
    end
    result
  },
 
  'list' => proc { |args|
    ret = []
    args.each do |arg|
      ret << arg
    end
    ret
  },

  'equal?' => proc { |args|
    args.first == args.last
  },
  
  'display' => proc { |args|
    print args.first.to_s
  }

}

$built_in_macros = { 
  'apply' => proc { |args|
    ret = ''
    ret << args.first.evaluate
    args.last.evaluate.each do |val|
      ret << ' ' << val
    end
    Parser.new.parse("(#{ret})").evaluate
  },

  'begin' => proc { |args|
    ret = ''
    args.each do |arg|
      ret << arg.to_s
    end
    print ret
    puts "\n"
    Parser.new.parse(ret).evaluate
  },

  'if' => proc { |args|
    if args[0].evaluate
      Parser.new.parse(args[1].to_s).evaluate
    else
      if args[2]
        Parser.new.parse(args[2].to_s).evaluate
      end
    end
  }
}

class Parser < BabelBridge::Parser

  rule :expressions, many(:expression) do
    def evaluate
      expression.each do |e|
        e.evaluate
      end
    end
  end

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
      if $built_in_procs.include? proc_name
        new_args = []
        proc_args.each do |arg|
          new_args << arg.evaluate
        end
        $built_in_procs[proc_name].call new_args
      else
        $built_in_macros[proc_name].call proc_args
      end
    end
  end

  rule :expression, '(', many(:identifier, ' '), ')' do
    def evaluate
      proc_name = identifier[0].to_s
      proc_args = identifier[1..expression.length]
      if $built_in_procs.include? proc_name
        $built_in_procs[proc_name].call proc_args
      else
        new_args = []
        $built_in_macros[proc_name].call proc_args
      end
    end
  end

  rule :expression, :identifier do
    def evaluate
      identifier.evaluate
    end
  end

  rule :identifier, /[a-zA-Z_0-9\+\-\*\/\?]*/ do
    def evaluate
      to_s
    end
  end

  rule :identifier, :string do
    def evaluate
      string.evaluate
    end
  end

end

BabelBridge::Shell.new(Parser.new).start
