require 'mechanize'

class Judges::CF
  attr_reader :username, :verdict, :time, :memory

  def initialize
    account = Rails.configuration.x.settings.dig(:proxy_judge).dig(:codeforces)
    @username = account.dig(:username)
    @password = account.dig(:password)
    @agent = Mechanize.new
  end

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

  def submit!(problem_id, language, source_code)
    language_regexp =  /.*GNU G\+\+20.*/ # TODO lookup this value by param language
    page = logged_in_get('https://codeforces.com/problemset/submit')
    form = page.forms.find { |f| f.has_field? 'source' }
    form.submittedProblemCode = problem_id
    form.source = source_code
    form.field_with(name: 'programTypeId').options
      .find { |o| o.text =~ language_regexp }
      .select
    page = form.submit
    status_row = page.search('tr[data-submission-id]').first.search('td')
    @submission_path = status_row[0].search('a')[0]['href']
    page.search('script').text =~ /submitted successfully/
  end

  def done?
    status = fetch_submission_status
    verdict = status["verdict"]
    not (verdict.include?("ing") or verdict.empty?)
  end

  def summary!
    status = fetch_submission_status
    @verdict = format_verdict(status["verdict"])
    @time = status["time"].to_i
    @memory = status["memory"].to_i
  end

  private

  def fetch_submission_status
    page = logged_in_get("https://codeforces.com/#{@submission_path}")
    last_submission_row = page.search('.datatable tr')[1]
    submission_details = last_submission_row.search('td').map(&:text).map(&:strip)
    keys = %w(run_id username problem_name language verdict time memory send_time judged_time favorite compare)
    Hash[keys.zip(submission_details)]
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
