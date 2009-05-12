all:
	./compiler.rb > code.s
	gcc -o code code.s

run: all
	./code

clean:
	rm code*
