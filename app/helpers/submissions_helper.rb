module SubmissionsHelper
  def censored(s)
    return false if user_signed_in? and current_user.admin?
    return false if user_signed_in? and current_user.id == s.user_id
    if s.contest && Time.now >= s.contest.start_time && Time.now <= s.contest.end_time
      return true if not user_signed_in?
      return true if user_signed_in? and current_user.id != s.user_id
    end
    return false
  end

  def compiler_list
    return [
      ["c++14/gnu c++ compiler 8.1.0 | options: -O2 -std=c++14", "c++14"],
      ["c++17/gnu c++ compiler 8.1.0 | options: -O2 -std=c++17", "c++17"],
      ["c++11/gnu c++ compiler 8.1.0 | options: -O2 -std=c++11", "c++11"],
      ["c++98/gnu c++ compiler 8.1.0 | options: -O2 -std=c++98", "c++98"],
      ["c11/gnu c compiler 8.1.0 | options: -O2 -std=c11 -lm", "c11"],
      ["c99/gnu c compiler 8.1.0 | options: -O2 -std=c99 -lm", "c99"],
      ["c90/gnu c compiler 8.1.0 | options: -O2 -ansi -lm", "c90"],
      ["python2/CPython 2.7.12 | options: -m py_compile", "python2"],
      ["python3/CPython 3.6.7 | options: -m py_compile", "python3"],
      ["haskell/glasgow haskell compiler 7.10.3 with haskell platform | options: -O", "haskell"]
    ]
  end
  def compiler_name(id)
    return compiler_list[id][1]
  end

  def language_class(lang)
    case lang
    when 0..3
      return "language-cpp"
    when 4..6
      return "language-c"
    when 9
      return "language-haskell"
    when 7..8
      return "language-python"
    else
      return "language-clike"
    end
  end
end
