#!/usr/bin/env ruby
#
# Writing a compiler in Ruby bottom up - step 11
# http://www.hokstad.com/writing-a-compiler-in-ruby-bottom-up-step-11.html

require 'emitter'

DO_BEFORE= []
DO_AFTER= []

class Function
  attr_reader :args,:body
  def initialize args,body
    @args = args
    @body = body
  end
end

class Scope
  def initialize compiler,func
    @c = compiler
    @func = func
  end

  def get_arg a
    a = a.to_sym
    @func.args.each_with_index {|arg,i| return [:arg,i] if arg == a }
    return [:addr,a]
  end
end

class Compiler
  attr_reader :global_functions

  def initialize
    @e = Emitter.new
    @global_functions = {}
    @string_constants = {}
  end

  def get_arg(scope,a)
    return compile_exp(scope,a) if a.is_a?(Array)
    return [:int, a] if (a.is_a?(Fixnum))
    return scope.get_arg(a) if (a.is_a?(Symbol))

    lab = @string_constants[a]
    if !lab
      lab = @e.get_local
      @string_constants[a] = lab
    end
    return [:strconst,lab]
  end

  def output_constants
    @e.rodata { @string_constants.each { |c,l| @e.string(l,c) } }
  end

  def output_functions
    @global_functions.each do |name,func|
      @e.func(name) { compile_exp(Scope.new(self,func),func.body) }
    end
  end

  def compile_defun scope,name, args, body
    @global_functions[name] = Function.new(args,body)
    return [:addr,name]
  end

  def compile_ifelse scope,cond, if_arm,else_arm = nil
    compile_exp(scope,cond)
    l_else_arm = @e.get_local
    l_end_if_arm = @e.get_local
    @e.jmp_on_false(l_else_arm)
    compile_exp(scope,if_arm)
    @e.jmp(l_end_if_arm) if else_arm
    @e.local(l_else_arm)
    compile_exp(scope,else_arm) if else_arm
    @e.local(l_end_if_arm) if else_arm
    return [:subexpr]
  end

  def compile_lambda scope,args, body
    compile_defun(scope,@e.get_local, args,body)
  end

  def compile_eval_arg scope,arg
    atype, aparam = get_arg(scope,arg)
    return aparam if atype == :int
    return @e.addr_value(aparam) if atype == :strconst
    @e.load_address(aparam) if atype == :addr
    @e.load_arg(aparam) if atype == :arg
    return @e.result_value
  end

  def compile_assign scope, left, right
    source = compile_eval_arg(scope, right)
    atype, aparam = get_arg(scope,left)
    raise "Expected an argument on left hand side of assignment" if atype != :arg
    @e.save_to_arg(source,aparam)
    return [:subexpr]
  end

  def compile_call scope,func, args
    @e.with_stack(args.length) do
      args.each_with_index do |a,i| 
        param = compile_eval_arg(scope,a)
        @e.save_to_stack(param,i)
      end
      @e.call(compile_eval_arg(scope,func))
    end
    return [:subexpr]
  end

  def compile_do(scope,*exp)
    exp.each { |e| compile_exp(scope,e) } 
    return [:subexpr]
  end

  def compile_while(scope, cond, body)
    @e.loop do |br|
      var = compile_eval_arg(scope,cond)
      @e.jmp_on_false(br)
      compile_exp(scope,body)
    end
    return [:subexpr]
  end

  def compile_exp(scope,exp)
    return if !exp || exp.size == 0
    return compile_do(scope,*exp[1..-1]) if exp[0] == :do 
    return compile_defun(scope,*exp[1..-1]) if (exp[0] == :defun)
    return compile_ifelse(scope,*exp[1..-1]) if (exp[0] == :if)
    return compile_lambda(scope,*exp[1..-1]) if (exp[0] == :lambda)
    return compile_assign(scope,*exp[1..-1]) if (exp[0] == :assign) 
    return compile_while(scope,*exp[1..-1]) if (exp[0] == :while)
    return compile_call(scope,exp[1],exp[2]) if (exp[0] == :call)
    return compile_call(scope,exp[0],exp[1..-1])
  end

  def compile_main(exp)
    @e.main do
      @main = Function.new([],[])
      compile_exp(Scope.new(self,@main),exp)
    end

    output_functions
    output_constants
  end

  def compile(exp) 
    compile_main([:do, DO_BEFORE, exp, DO_AFTER]) 
  end  
end

