require 'rest-client'

class Judges::POJ
  # ref: http://poj.org/page?id=1000
  # "C", "C++" are MS VC++ 2008 Express and "GCC", "G++" are MinGW GCC 4.4.0
  PROXY_COMPILERS = {
    "c++98" => "G++",
    "c99" => "GCC",
  }.freeze

  LANGUAGES = %w(G++ GCC Java Pascal C++ C Fortran)
  REDIRECT_HANDLER = lambda do |response, request, result, &block|
    if response.code == 302
      response
    else
      response.return!(request, result, &block)
    end
  end

  SUBMISSION_REGEX = %r{
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
  }xm
  DETAIL_REGEX = %r{
    <tr><td><b>.*?</b>.*?<a.*?>(?<problem_id>.*?)</a></td>
    <td.*?></td>
    <td><b>.*?</b>.*?<a.*?>(?<username>.*?)</a></td>
    </tr>.*?
    <tr><td><b>.*?</b>.*?((?<memory>[0-9]+)K|N/A)</td>
    <td.*?></td>
    <td><b>.*?</b>.*?((?<time>[0-9]+)MS|N/A)</td>
    </tr>.*?
    <tr><td><b>.*?</b>.*?(?<language>\S+?)</td>
    <td.*?></td>
    <td><b>.*?</b>.*?((<a.*?>)?<font.*?>(?<verdict>.*?)</font>(</a>)?)?</td></tr>
  }xm

  attr_reader :username

  def initialize
    account = Rails.configuration.x.settings.dig(:proxyjudge).dig(:poj)
    @username = account.dig(:username)
    @password = account.dig(:password)
    @cookies = nil
  end

  def login
    return unless @cookies.nil?
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
    @cookies = login_response.cookies
  end

  def submit!(problem_id, compiler_name, source_code, _)
    if not PROXY_COMPILERS.include?(compiler_name) then
      raise 'Unknown compiler for POJ proxy judge'
    end
    proxy_language = PROXY_COMPILERS[compiler_name]

    login
    submit_response = RestClient.post(
      'http://poj.org/submit',
      {
        submit: 'Submit',
        problem_id: problem_id,
        language: LANGUAGES.index(proxy_language),
        source: [source_code].pack('m0'),
        encoded: 1
      },
      cookies: @cookies,
      &REDIRECT_HANDLER
    )
    return false if submit_response.code != 302
    update_submission_id
    return true
  end

  # TODO: fetch result job
  def fetch_submission_status(proxyjudge_args, proxyjudge_submission_id)
    get_status_dict fetch_submission_detail(proxyjudge_submission_id)
  end

  private

  def update_submission_id
    response = RestClient.get "http://poj.org/status?user_id=#{@username}"
    submission_ids = response.scan(SUBMISSION_REGEX).map{ |match| match[0] }
    identified_submissions = Submission.where(proxyjudge_id: submission_ids, proxyjudge_type: :poj).pluck(&:proxyjudge_id)
    unidentified_submissions = Submission.where(proxyjudge_id: nil, proxyjudge_type: :poj).map{|x| [x.proxyjudge_nonce, x]}.to_h
    submission_ids -= identified_submissions
    submission_ids.each do |submission_id|
      detail = fetch_submission_detail(submission_id)
      nonce = detail.scan(/tioj-proxy nonce=([0-9a-f]{64})/).last
      next if nonce.nil? || !unidentified_submissions.include?(nonce)
      unidentified_submissions[nonce].update(proxyjudge_id: submission_id)
      # TODO: also update result if available
    end
  end

  def get_status_dict(response)
    status = DETAIL_REGEX.match(response).named_captures
    verdict = status['verdict']
    return nil if verdict.nil? || verdict.empty? || verdict.include?("ing")
    {
      verdict: format_verdict(verdict),
      time: status['time'].to_i,
      memory: status['memory'].to_i,
    }
  end

  # submission_id is the ID of POJ (proxyjudge_id)
  def fetch_submission_detail(submission_id)
    login
    RestClient.get("http://poj.org/showsource?solution_id=#{submission_id}", cookies: @cookies)
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
    else "JE"
    end
  end
end
