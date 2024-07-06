require 'mechanize'

class Judges::CF
  PROXY_COMPILERS = {
    "c++17" => /.*GNU G\+\+17.*/,
    "c++20" => /.*GNU G\+\+20.*/,
    "c++14" => /.*GNU G\+\+14.*/,
    "c11" => /.*GNU GCC C11.*/,
    "python2" => /.*PyPy 2.*/,
    "python3" => /.*PyPy 3.*/,
    "haskell" => /.*Haskell.*/,
  }.freeze

  attr_reader :username, :verdict, :time, :memory

  def initialize
    account = Rails.configuration.x.settings.dig(:proxyjudge).dig(:codeforces)
    @username = account.dig(:username)
    @password = account.dig(:password)
    @agent = Mechanize.new
  end

  def submit!(problem_id, compiler_name, source_code, submission)
    if not PROXY_COMPILERS.include?(compiler_name) then
      raise 'Unknown compiler for Codeforces proxy judge'
    end
    regexp = PROXY_COMPILERS[compiler_name]

    page = logged_in_get('https://codeforces.com/problemset/submit')
    form = page.forms.find { |f| f.has_field? 'source' }
    form.submittedProblemCode = problem_id
    form.source = source_code
    form.field_with(name: 'programTypeId').options
      .find { |o| o.text =~ regexp }
      .select
    page = form.submit

    status_row = page.search('tr[data-submission-id]').first.search('td')
    return false unless page.search('script').text =~ /submitted successfully/

    @submission_path = status_row[0].search('a')[0]['href']
    # TODO gym and contest submissions have different url format
    submission_id = %r{/([0-9]+/[0-9]+)$}.match(@submission_path)[1]
    submission.update!(proxyjudge_id: submission_id)
    return true
  end

  def fetch_submission_status(proxyjudge_args, proxyjudge_submission_id)
    @submission_path = "/problemset/submission/#{proxyjudge_submission_id}"

    page = logged_in_get("https://codeforces.com/#{@submission_path}")
    submission_row = page.search('.datatable tr')[1]
    submission_details = submission_row.search('td').map(&:text).map(&:strip)
    keys = %w(run_id username problem_name language verdict time memory send_time judged_time favorite compare)
    status = Hash[keys.zip(submission_details)]
    verdict = status['verdict']
    return nil if verdict.nil? || verdict.empty? || verdict.include?("ing")
    {
      verdict: format_verdict(verdict),
      time: verdict.to_i,
      memory: verdict.to_i,
    }
  end

  private

  def login
    page = @agent.get('https://codeforces.com/enter')
    form = page.forms.find {|f| f.has_field? 'handleOrEmail'}
    form.handleOrEmail = @username
    form.password = @password
    form.submit
  end

  def logged_in?(page)
    page.search("a[href$='/logout']:not([class])").any? { |a| a.text == 'Logout' }
  end

  def logged_in_get(url)
    page = @agent.get(url)
    login unless logged_in?(page)
    page = @agent.get(url)
    raise 'Login Failed' unless logged_in?(page)
    page
  end

  def format_verdict(verdict)
    verdict = verdict.split.map(&:capitalize).join(' ')
    case verdict
    when /Accepted/ then "AC"
    when /Wrong Answer/ then "WA"
    when /Time Limit Exceeded/ then "TLE"
    when /Runtime Error/ then "RE"
    when /Memory Limit Exceeded/ then "MLE"
    when /Compilation Error/ then "CE"
    else verdict
    end
  end
end
