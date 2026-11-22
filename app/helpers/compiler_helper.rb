module CompilerHelper
  COMPILER_LIST = [
    ["language-cpp", ".cpp", "C++17 | GCC 15.2.0 | options: -O2 -std=c++17", "c++17"],
    ["language-cpp", ".cpp", "C++20 | GCC 15.2.0 | options: -O2 -std=c++20", "c++20"],
    ["language-cpp", ".cpp", "C++23 | GCC 15.2.0 | options: -O2 -std=c++23", "c++23"],
    ["language-cpp", ".cpp", "C++14 | GCC 15.2.0 | options: -O2 -std=c++14", "c++14"],
    ["language-cpp", ".cpp", "C++11 | GCC 15.2.0 | options: -O2 -std=c++11", "c++11"],
    ["language-cpp", ".cpp", "C++98 | GCC 15.2.0 | options: -O2 -std=c++98", "c++98"],
    ["language-c", ".c", "C23 | GCC 15.2.0 | options: -O2 -std=c23 -lm", "c23"],
    ["language-c", ".c", "C17 | GCC 15.2.0 | options: -O2 -std=c17 -lm", "c17"],
    ["language-c", ".c", "C11 | GCC 15.2.0 | options: -O2 -std=c11 -lm", "c11"],
    ["language-c", ".c", "C99 | GCC 15.2.0 | options: -O2 -std=c99 -lm", "c99"],
    ["language-c", ".c", "C90 | GCC 15.2.0 | options: -O2 -ansi -lm", "c90"],
    ["language-python", ".py", "Python 2 | CPython 2.7.18 | options: -m py_compile", "python2"],
    ["language-python", ".py", "Python 3 | CPython 3.14.10 with NumPy 2.5 & Pillow 13 | options: -m py_compile", "python3"],
    ["language-haskell", ".hs", "Haskell | GHC 9.10.3 | options: -O -with-rtsopts=-V0", "haskell"],
    ["language-rust", ".rs", "Rust 2021 | rustc 1.93.1 | options: -O --edition=2021", "rust 2021"],
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
