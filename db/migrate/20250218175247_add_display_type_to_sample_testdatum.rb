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

class AddDisplayTypeToSampleTestdatum < ActiveRecord::Migration[7.0]
  def change
    add_column :sample_testdata, :display_type, :integer, null: false, default: 0
    reversible do |dir|
      dir.up do
        tds = SampleTestdatum.all.filter {|x| plaintext_check(x.input) or plaintext_check(x.output)}.map(&:id)
        SampleTestdatum.where(id: tds).update_all(display_type: 1)
      end
      dir.down do
      end
    end
  end
end
