module CompilerHelper
  COMPILER_LIST = [
    ["language-cpp", ".cpp", "c++17/gnu c++ compiler 11.2.0 | options: -O2 -std=c++17", "c++17"],
    ["language-cpp", ".cpp", "c++20/gnu c++ compiler 11.2.0 | options: -O2 -std=c++20", "c++20"],
    ["language-cpp", ".cpp", "c++14/gnu c++ compiler 11.2.0 | options: -O2 -std=c++14", "c++14"],
    ["language-cpp", ".cpp", "c++11/gnu c++ compiler 11.2.0 | options: -O2 -std=c++11", "c++11"],
    ["language-cpp", ".cpp", "c++98/gnu c++ compiler 11.2.0 | options: -O2 -std=c++98", "c++98"],
    ["language-c", ".c", "c17/gnu c compiler 11.2.0 | options: -O2 -std=c17 -lm", "c17"],
    ["language-c", ".c", "c11/gnu c compiler 11.2.0 | options: -O2 -std=c11 -lm", "c11"],
    ["language-c", ".c", "c99/gnu c compiler 11.2.0 | options: -O2 -std=c99 -lm", "c99"],
    ["language-c", ".c", "c90/gnu c compiler 11.2.0 | options: -O2 -ansi -lm", "c90"],
    ["language-python", ".py", "python2/CPython 2.7.18 | options: -m py_compile", "python2"],
    ["language-python", ".py", "python3/CPython 3.10.4 with numpy & PIL | options: -m py_compile", "python3"],
    ["language-haskell", ".hs", "haskell/glasgow haskell compiler 8.8.4 with haskell platform | options: -O", "haskell"],
  ]

  def self.generate_table
    to_delete = Compiler.all.map{|x| x.name}.to_a - COMPILER_LIST.map{|x| x[3]}.to_a
    Compiler.where(name: to_delete).destroy_all
    to_update = COMPILER_LIST.map.with_index{|x, index|
      {name: x[3], description: x[2], format_type: x[0], extension: x[1], order: index}
    }
    Compiler.import(to_update, on_duplicate_key_update: [:description, :format_type, :extension, :order])
  end
  def generate_table
    CompilerHelper.generate_table
  end
end
