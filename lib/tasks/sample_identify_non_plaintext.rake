namespace :sample do
  desc "Identify non-plaintext samples"
  task identify_non_plaintext: :environment do
    samples = SampleTestdatum.where(
      "input LIKE ? OR input LIKE ? OR input LIKE ? OR input LIKE ? OR
       output LIKE ? OR output LIKE ? OR output LIKE ? OR output LIKE ?",
       '%$%$%', '%\\\\(%\\\\)%', '%\\\\[%\\\\]%', '%<%>%',
       '%$%$%', '%\\\\(%\\\\)%', '%\\\\[%\\\\]%', '%<%>%'
    )
    puts "The following samples may contain non-plaintext content."
    puts "They are currently marked as non-plaintext and rendered as before, but it is advised to review them manually and change them to plaintext format if possible."
    samples.each do |sample|
      puts "------------------------------------------------------------------------------"
      puts "Problem ##{sample.problem.id}"
      if ENV['detail'] == '1'
        puts "Input:"
        puts sample.input
        puts "Output:"
        puts sample.output
      end

      def detail_check(section, text)
        escaped_text = ApplicationController.helpers.escape_once(text)
        before_html = Nokogiri::HTML("<div>#{text}</div>")
        after_html = Nokogiri::HTML("<pre>#{escaped_text}</pre>")
        if escaped_text != text
          puts "some html escape character detected in #{section}."
        end
        if before_html.text != after_html.text
          puts "html-tag detected in #{section}."
          if ENV['detail'] == '1'
            puts "before: #{before_html.text}"
            puts "after: #{after_html.text}"
          end
        end

        mathjax_regex = /(
          \$(.*)\$ |        # $ ... $
          \\\[(.*?)\\\] |   # \[ ... \]
          \\\((.*?)\\\)     # \( ... \)
        )/mx
        matches = text.scan(mathjax_regex).map(&:first).compact
        if matches.any?
          puts "mathjax detected in #{section}: #{matches}"
        end
      end
      detail_check("input", sample.input)
      detail_check("output", sample.output)
    end
  end
end
