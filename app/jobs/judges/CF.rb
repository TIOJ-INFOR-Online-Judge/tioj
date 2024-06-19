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
    page.search("a[href$='/logout']:not([class])").any? {|a| a.text == 'Logout'}
  end

  def logged_in_get(url)
    page = @agent.get(url)
    login unless logged_in?(page)
    page = @agent.get(url)
    raise 'Login Failed' unless logged_in?(page)
    page
  end

  def submit(problem_id, language, source_code)
    page = logged_in_get('https://codeforces.com/problemset/submit')
    form = page.forms.find {|f| f.has_field? 'source'}
    form.submittedProblemCode = problem_id
    form.source = source_code
    form.field_with(name: 'programTypeId').options.each do |o|
      if o.text =~ language then
        o.select
      end
    end
    page = form.submit
    status_row = page.search('tr[data-submission-id]').first.search('td')
    # Rails.logger.info(status_row[0])
    @submission_path = status_row[0].search('a')[0]['href']
    # Rails.logger.info(@submission_path)
    page.search('script').text =~ /submitted successfully/
  end

  def done?
    page = logged_in_get("https://codeforces.com/#{@submission_path}")
    # Rails.logger.info(page.search('tr.highlighted-row'))
    last_submission_row = page.search('.datatable tr')[1]
    @status = Hash[
      %w(run_id username problem_name language verdict time memory send_time judged_time favorite compare)
      .zip last_submission_row.search('td').map{|td| td.text.strip}
    ]
    # Rails.logger.info("THIS IS THE STATUS!!!")
    # Rails.logger.info(@status)

    @verdict = @status["verdict"]
    @verdict = @verdict.split.map(&:capitalize).join(' ')
    # Rails.logger.info(@verdict)
    if @verdict.include? "Accepted"
      @verdict = "AC"
    elsif @verdict.include? "Wrong Answer"
      @verdict = "WA"
    elsif @verdict.include? "Time Limit Exceeded"
      @verdict = "TLE"
    elsif @verdict.include? "Runtime Error"
      @verdict = "RE"
    elsif @verdict.include? "Memory Limit Exceeded"
      @verdict = "MLE"
    end
    @time = @status["time"].to_i
    @memory = @status["memory"].to_i
    not (@verdict.include?("ing") or @verdict.empty?)
  end

end
