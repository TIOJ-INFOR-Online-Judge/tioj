module CompilerHelper
  COMPILER_LIST = [
    ["language-cpp", "c++14/gnu c++ compiler 8.1.0 | options: -O2 -std=c++14", "c++14"],
    ["language-cpp", "c++17/gnu c++ compiler 8.1.0 | options: -O2 -std=c++17", "c++17"],
    ["language-cpp", "c++11/gnu c++ compiler 8.1.0 | options: -O2 -std=c++11", "c++11"],
    ["language-cpp", "c++98/gnu c++ compiler 8.1.0 | options: -O2 -std=c++98", "c++98"],
    ["language-c", "c11/gnu c compiler 8.1.0 | options: -O2 -std=c11 -lm", "c11"],
    ["language-c", "c99/gnu c compiler 8.1.0 | options: -O2 -std=c99 -lm", "c99"],
    ["language-c", "c90/gnu c compiler 8.1.0 | options: -O2 -ansi -lm", "c90"],
    ["language-python", "python2/CPython 2.7.12 | options: -m py_compile", "python2"],
    ["language-python", "python3/CPython 3.6.7 | options: -m py_compile", "python3"],
    ["language-haskell", "haskell/glasgow haskell compiler 7.10.3 with haskell platform | options: -O", "haskell"]
  ]

  def self.generate_table
    ActiveRecord::Base.connection.truncate(:compilers)
    Compiler.create(COMPILER_LIST.map{|x| {:name => x[2], :description => x[1], :format_type => x[0]}})
  end
  def generate_table
    CompilerHelper.generate_table
  end
  def compiler_id_name(id)
    return COMPILER_LIST[id - 1][2]
  end
end
