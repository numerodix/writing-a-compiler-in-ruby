run: all
	./step9

all: parser

parser: parser.o runtime.o

parser.o: parser.s

parser.s: parser.rb
	ruby parser.rb >parser.s


parser2: parser2.o runtime.o

parser2.o: parser2.s

parser2.s: parser2.rb
	ruby parser2.rb >parser2.s

clean:
	rm -f *~ *.o *.s parser parser2


