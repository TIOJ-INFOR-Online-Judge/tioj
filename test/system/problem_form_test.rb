require "application_system_test_case"

class ProblemFormTest < ApplicationSystemTestCase
  # The visible text entry of the tag widget (jquery.tagsinput or Tom Select).
  TAG_ENTRY = "#problem_tag_list_tag, #problem_tag_list-ts-control"
  # The rendered tag chips of the same widget.
  TAG_CHIPS = "#problem_tag_list_tagsinput .tag, #problem_tag_list + .ts-wrapper .item"

  setup do
    @problem = problems(:one)
    sign_in users(:adminOne)
  end

  test "a typed tag is kept when the form is submitted without confirming it" do
    visit edit_problem_path(@problem)

    find(TAG_ENTRY).send_keys("pending-tag")
    click_button "Update Problem"

    assert_text "Problem was successfully updated."
    assert_includes @problem.reload.tag_list, "pending-tag"
  end

  test "re-entering an existing tag does not duplicate it" do
    @problem.update!(tag_list: "graph, greedy")
    visit edit_problem_path(@problem)
    assert_selector TAG_CHIPS, count: 2

    find(TAG_ENTRY).send_keys("greedy", :enter)
    assert_selector TAG_CHIPS, count: 2
    assert_equal ["graph", "greedy"], all(TAG_CHIPS).map { |chip| chip_label(chip) }
  end

  test "an added sample testdatum uses the same layout as the existing one" do
    visit edit_problem_path(@problem)
    assert_selector "textarea.code-input[id$='_input']", count: 1

    click_link "Add sample testdatum"
    assert_selector "textarea.code-input[id$='_input']", count: 2

    existing_width, added_width = sample_input_widths
    assert_in_delta existing_width, added_width, existing_width * 0.05,
      "the added sample input should be as wide as the existing one"
  end

  private

  # Chip text without the widget's remove control (an "x" link or a "×" button).
  def chip_label(chip)
    chip.evaluate_script(<<~JS)
      Array.from(this.childNodes)
        .filter((node) => node.nodeType === Node.TEXT_NODE || node.matches("span"))
        .map((node) => node.textContent)
        .join("")
        .replace(/\\u00a0/g, " ")
        .trim()
    JS
  end

  def sample_input_widths
    evaluate_script(<<~JS)
      Array.from(document.querySelectorAll("textarea.code-input[id$='_input']"))
        .map((element) => element.getBoundingClientRect().width)
    JS
  end
end
