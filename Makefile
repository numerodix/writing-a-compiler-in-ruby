run:
	make parser
	-./parser < parser.l > parser2.rb
	make parser2
	-./parser2 < parser.l > parser3.rb
	diff -B parser2.rb parser3.rb

all: parser

parser: parser.o runtime.o

parser.o: parser.s

parser.s: parser.rb
	ruby parser.rb >parser.s


parser2: parser2.o runtime.o

parser2.o: parser2.s

parser2.s: parser2.rb parser
	ruby parser2.rb >parser2.s

parser2.rb: parser.l parser
	@./parser <parser.l >parser2.rb

clean:
	rm -f *~ *.o *.s parser parser2* parser3*


