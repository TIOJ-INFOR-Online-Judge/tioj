require 'rest-client'

class Judges::POJ
  LANGUAGES = %w(G++ GCC Java Pascal C++ C Fortran)
  REDIRECT_HANDLER = lambda do |response, request, result, &block|
    if response.code == 302
      response
    else
      response.return!(request, result, &block)
    end
  end

  attr_reader :username, :verdict, :time, :memory

  def initialize
    account = Rails.configuration.x.settings.dig(:proxy_judge).dig(:poj)
    @username = account.dig(:username)
    @password = account.dig(:password)
  end

  def submit!(problem_id, language, source_code)
    language = 'G++' # TODO lookup by a Hash
    login_response = RestClient.post(
      'http://poj.org/login',
      {
        B1: 'login',
        url: '/',
        user_id1: @username,
        password1: @password
      },
      &REDIRECT_HANDLER
    )
    submit_response = RestClient.post(
      'http://poj.org/submit',
      {
        submit: 'Submit',
        problem_id: problem_id,
        language: LANGUAGES.index(language),
        source: [source_code].pack('m0'),
        encoded: 1
      },
      cookies: login_response.cookies,
      &REDIRECT_HANDLER
    )
    submit_response.code == 302
  end

  def done?
    status = fetch_submission_status
    # Rails.logger.info "status = #{status}"
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
    # TODO when handling multiple simutaneous submissions, looking for the latest submission is wrong
    response = RestClient.get "http://poj.org/status?user_id=#{@username}"
    match = %r{
      <tr\salign=center>
      <td>(?<run_id>.*?)</td>
      <td><a\shref=userstatus\?user_id=.*?>(?<username>.*?)</a></td>
      <td><a\shref=problem\?id=.*?>(?<problem_id>.*?)</a></td>
      <td>(<a.*?>)?<font\scolor=.*?>(?<verdict>.*?)</font>(</a>)?</td>
      <td>(?<memory>.*?)K?</td>
      <td>(?<time>.*?)(MS)?</td>
      <td>(?<language>.*?)</td>
      <td>(?<code_length>.*?)B</td>
      <td>(?<submit_time>.*?)</td>
      </tr>
    }xm.match(response)
    Hash[match.names.zip(match.captures)]
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
