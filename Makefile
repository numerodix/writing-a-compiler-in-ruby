run:
	make testarray
	@echo "====> run ./testarray"
	-./testarray
	make testargs
	@echo "====> run ./testargs"
	-./testargs
	@echo "====> test ./parser"
	make parser
	-./parser < parser.l > parser2.rb
	make parser2
	-./parser2 < parser.l > parser3.rb
	diff -B parser2.rb parser3.rb

all: parser

parser: parser.o runtime.o

parser.o: parser.s

parser.s: parser.l
	ruby compiler.rb <parser.l >parser.s

parser2: parser2.o runtime.o

parser2.o: parser2.s

parser2.s: parser.l
	ruby compiler.rb <parser.l >parser2.s

clean:
	@rm -f *~ *.o *.s parser parser2* parser3* testarray testargs

testarray.s: testarray.l
	ruby compiler.rb <testarray.l >testarray.s

testarray.o: testarray.s 

testarray: testarray.o runtime.o
	gcc -o testarray testarray.o runtime.o

testargs.s: testargs.l
	ruby compiler.rb <testargs.l >testargs.s

testargs.o: testargs.s

testargs: testargs.o runtime.o
