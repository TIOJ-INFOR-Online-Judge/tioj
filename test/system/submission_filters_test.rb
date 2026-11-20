require "application_system_test_case"

class SubmissionFiltersTest < ApplicationSystemTestCase
  test "compiler filter submits only a listed compiler ID" do
    compiler = compilers(:c99)
    assert_fixed_filter("filter_compiler", compiler.name, compiler.id.to_s)
  end

  test "verdict filter submits only a listed verdict code" do
    assert_fixed_filter("filter_status", "Accepted", "AC")
  end

  private

  def assert_fixed_filter(field, label, value)
    visit submissions_path
    within(find("select##{field}", visible: :all).find(:xpath, "..")) do
      control = find("[role=combobox]")
      control.click
      # A searchable menu may accept typing, but only listed values can be selected.
      if control.tag_name == "input"
        assert_selector "[role=option]", exact_text: label
        control.set("nonexistent-option")
        assert_no_selector "[role=option]", exact_text: label
        control.send_keys(:enter)
        assert_no_selector "option[value='nonexistent-option']:checked", visible: :all
        control.click
        control.set(label)
      end
      find("[role=option]", exact_text: label).click
    end
    click_button "Filter"

    assert_current_path(/\A#{Regexp.escape(submissions_path)}\?/)
    assert_equal [value], Rack::Utils.parse_nested_query(URI.parse(current_url).query)[field]
    assert_link submissions(:ac).id.to_s, href: submission_path(submissions(:ac))
  end
end
