
require 'compiler'

prog = [:do,
  [[:lambda, [:i], [:do,
        [:assign, :i, [:array, 2]],
        [:printf, "i=%p\n",:i],
        [:assign, [:index, :i, 0], 2],
        [:assign, [:index, :i, 1], 42],
        [:printf, "i[0]=%ld, i[1]=%ld\\n",[:index,:i,0],[:index,:i,1]]
      ]
    ],10]
]

Compiler.new.compile(prog)

    
