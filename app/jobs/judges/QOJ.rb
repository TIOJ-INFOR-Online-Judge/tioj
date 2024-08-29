require 'mechanize'
require 'digest'

class Judges::QOJ
  PROXY_COMPILERS = {
    "c++98" => "C++98",
    "c++11" => "C++11",
    "c++14" => "C++14",
    "c++17" => "C++17",
    "c++20" => "C++20",
    "c11" => "C11",
    "python3" => "Python3",
  }.freeze

  def initialize
    if not @username
      account = Rails.configuration.x.settings.dig(:proxyjudge).dig(:qoj)
      @username = account.dig(:username)
      @password = account.dig(:password)
      @agent = Mechanize.new
    end
  end

  # problem_id = contest_name/id
  def submit!(problem_id, compiler_name, source_code, submission)
    if not PROXY_COMPILERS.include?(compiler_name) then
      raise 'Unknown compiler for QOJ proxy judge'
    end
    language = PROXY_COMPILERS[compiler_name]

    page = logged_in_get("https://qoj.ac/problem/#{problem_id}")
    form = page.forms.find {|f| f.has_field? '_token'}
    form.add_field!('answer_answer_upload_type', value = 'editor')
    form.add_field!('answer_answer_editor', value = source_code)
    form.add_field!('answer_answer_language', value = language)
    form.add_field!('submit-answer', value = 'answer')
    page = form.submit

    # Rails.logger.error "page=#{page.uri} row=#{page.search('tr')}"
    submission_path = page.search('tr')[1].search('a')[0]['href']
    submission_path = submission_path.to_s.force_encoding("UTF-8")
    # Rails.logger.error "submission_path=#{submission_path}"
    submission_id =  %r{/submission/([0-9]+)}.match(submission_path)[1]
    submission.update!(proxyjudge_id: submission_id)

    return true
  end

  def fetch_results
    Rails.logger.info "FETCH_RESULTS"
    subs = Submission.where(result: 'received', proxyjudge_type: :qoj).all
    Rails.logger.info "subs = #{subs}"
    return false if subs.empty?
    update_hash = []
    subs.any? do |submission|
      status = fetch_submission_status(submission.proxyjudge_id)
      if status
        update_hash << status.update(id: submission.id)
      end
      not status
    end
    Submission.import(
      update_hash.map {|x| x.update(compiler_id: -1, code_content_id: -1)},
      on_duplicate_key_update: [:result, :score, :total_time, :total_memory], validate: false)
    update_hash.each{ |x|
      ActionCable.server.broadcast("submission_#{x[:id]}_overall", x)
    }
  end

  private

  def fetch_submission_status(submission_id)
    page = logged_in_get("https://qoj.ac/submission/#{submission_id}")
    keys = %w(submission_id problem_name username verdict time memory language code_size submit_time)

    status = Hash[keys.zip(
      page.search('tr')[1]
      .search('td')
      .map(&:text).map(&:strip)
    )]
    Rails.logger.info "status=#{status}"
    verdict = status['verdict']
    return nil if verdict.nil? || verdict.empty? || verdict.include?("ing")

    # TODO: fetch CE message?
    verdict = format_verdict(verdict)
    {
      result: verdict,
      score: verdict == 'AC' ? 100 : 0,
      total_time: status['time'].split[0].to_i,
      total_memory: status['memory'].split[0].to_i,
    }
  end

  def format_verdict(verdict)
    case verdict
    when /AC/ then "AC"
    when /.*✓.*/ then "AC"
    when /WA/ then "WA"
    when /TL/ then "TLE"
    when /RE/ then "RE"
    when /ML/ then "MLE"
    when /Compile Error/ then "CE"
    # TODO for partial score problems, the result field would be the score
    when /[0-9]+/ then "WA"
    else "JE"
    end
  end

  def get_token(page)
    script = page.search('script').select { |s| s.text.include?('_token') }.to_s
    token_start = '_token : \\"'
    token_end = '\\",'
    return script[/#{Regexp.escape(token_start)}(.*?)#{Regexp.escape(token_end)}/m, 1]
  end

  def login
    page = @agent.get('https://qoj.ac/login')
    form = page.forms.find {|f| f.has_field? 'username'}
    form.add_field!('_token', value = get_token(page))
    form.add_field!('login', value = '')
    form.username = @username
    form.password = Digest::MD5.hexdigest @password
    page = form.submit
  end

  def logged_in?(page)
    not page.body.include?('Login')
  end

  def logged_in_get(url)
    page = @agent.get(url)
    login unless logged_in?(page)
    page = @agent.get(url)
    raise 'Login Failed' unless logged_in?(page)
    page
  end
end
