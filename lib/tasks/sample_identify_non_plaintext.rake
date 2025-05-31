def plaintext_check(text)
  escaped_text = ApplicationController.helpers.escape_once(text)
  before_html = Nokogiri::HTML("<div>#{text}</div>")
  after_html = Nokogiri::HTML("<pre>#{escaped_text}</pre>")
  return :escape if escaped_text != text
  return :html if before_html.text != after_html.text

  mathjax_regex = /(
    \$(.*)\$ |        # $ ... $
    \\\[(.*?)\\\] |   # \[ ... \]
    \\\((.*?)\\\)     # \( ... \)
  )/mx
  matches = text.scan(mathjax_regex).map(&:first).compact
  return :mathjax if matches.any?
end

def check_and_print_sample(sample)
  input_mode = plaintext_check(sample.input)
  output_mode = plaintext_check(sample.output)
  return unless input_mode or output_mode or sample.display_raw_html?
  puts "------------------------------------------------------------------------------"
  puts "Problem ##{sample.problem.id}"
  if ENV['detail'] == '1'
    puts "Input:"
    puts sample.input
    puts "Output:"
    puts sample.output
  end
  puts "Marked as non-plaintext" unless sample.display_plaintext?

  def print_result(section, mode)
    if mode == :escape
      puts "some html escape character detected in #{section}."
    elsif mode == :html
      puts "html-tag detected in #{section}."
      if ENV['detail'] == '1'
        puts "before: #{before_html.text}"
        puts "after: #{after_html.text}"
      end
    elsif mode == :mathjax
      puts "mathjax detected in #{section}."
    end
  end
  print_result("input", input_mode)
  print_result("output", output_mode)
end

namespace :sample do
  desc "Identify non-plaintext samples"
  task identify_non_plaintext: :environment do
    puts "The following samples may contain non-plaintext content."
    puts "They are currently marked as non-plaintext and rendered as before, but it is advised to review them manually and change them to plaintext format if possible."
    SampleTestdatum.all.each(&method(:check_and_print_sample))
  end
end
