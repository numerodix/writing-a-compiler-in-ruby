#!/usr/bin/env ruby
#
# Writing a compiler in Ruby bottom up - step 1
# http://www.hokstad.com/writing-a-compiler-in-ruby-bottom-up-step-1.html

class Compiler

  def compile(exp)
    # Taken from gcc -S output
    puts <<PROLOG
	.file	"bootstrap.rb"
	.text
.globl main
	.type	main, @function
main:
	leal	4(%esp), %ecx
	andl	$-16, %esp
	pushl	-4(%ecx)
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ecx
PROLOG

    puts <<EPILOG
	popl	%ecx
	popl	%ebp
	leal	-4(%ecx), %esp
	ret
EPILOG

    puts <<GLOBAL_EPILOG
	.size	main, .-main
GLOBAL_EPILOG
  end
end

prog = [:puts,"Hello World"]

Compiler.new.compile(prog)
