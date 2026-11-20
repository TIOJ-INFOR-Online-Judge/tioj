require "application_system_test_case"

class SubmissionFiltersTest < ApplicationSystemTestCase
  test "compiler filter submits the selected compiler ID" do
    compiler = compilers(:c99)
    assert_filter_submission("filter_compiler", compiler.name, compiler.id.to_s)
  end

  test "verdict filter submits the selected verdict code" do
    assert_filter_submission("filter_status", "Accepted", "AC")
  end

  # TODO: Test rejection of arbitrary input when the filters become searchable.

  private

  def assert_filter_submission(field, label, value)
    visit submissions_path
    within(find("select##{field}", visible: :all).find(:xpath, "..")) do
      find("[role=combobox]").click
      find("[role=option]", exact_text: label).click
    end
    click_button "Filter"

    assert_current_path(/\A#{Regexp.escape(submissions_path)}\?/)
    assert_equal [value], Rack::Utils.parse_nested_query(URI.parse(current_url).query)[field]
    assert_link submissions(:ac).id.to_s, href: submission_path(submissions(:ac))
  end
end
