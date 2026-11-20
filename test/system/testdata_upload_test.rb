require "application_system_test_case"

class TestdataUploadTest < ApplicationSystemTestCase
  test "single testdatum upload callbacks display progress and processing status" do
    sign_in users(:adminOne)
    visit new_problem_testdatum_path(problems(:one))

    # Stub the upload transport and drive the progress callback through both UI states.
    page.execute_script(<<~JS)
      window.ajaxUploadFunc = () => (url, data, onProgress) => {
        window.reportUploadProgress = onProgress;
        onProgress(false, { loaded: 50, total: 100, byterate: 10 });
      };
      $("#testdata-form").triggerHandler("submit");
    JS
    assert_selector "#progress-text", text: "50.00 %"
    find("#progress-fade").assert_matches_style(opacity: "1")

    page.execute_script("window.reportUploadProgress(true)")
    assert_selector "#progress-text", text: "Processing..."
  end
end
