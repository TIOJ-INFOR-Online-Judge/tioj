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
    if not @username
      account = Rails.configuration.x.settings.dig(:proxyjudge).dig(:poj)
      @username = account.dig(:username)
      @password = account.dig(:password)
      @cookies = nil
    end
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
    return submit_response.code == 302
  end

  def fetch_results
    response = RestClient.get "http://poj.org/status?user_id=#{@username}&size=100"
    # find all matches with MatchData
    submission_data = response.to_enum(:scan, SUBMISSION_REGEX).map {$~}

    submission_ids = submission_data.map{ |match| match[:run_id] }
    identified_submissions = Submission.where(proxyjudge_id: submission_ids, proxyjudge_type: :poj).map{|x| [x.proxyjudge_id, x]}.to_h
    unidentified_submissions = Submission.where(proxyjudge_id: nil, proxyjudge_type: :poj).map{|x| [x.proxyjudge_nonce, x]}.to_h
    submission_ids -= identified_submissions.keys
    submission_id_set = submission_ids.to_set
  
    result = false
    submission_ids.each do |submission_id|
      next if submission_id_set.empty?
      detail = fetch_submission_detail(submission_id)
      nonce = detail.scan(/tioj-proxy nonce=([0-9a-f]{64})/).last&.first
      next if nonce.nil? || !unidentified_submissions.include?(nonce)
      submission_id_set.delete(submission_id)
      sub = unidentified_submissions[nonce]
      status = get_status_dict_from_detail(detail)
      result = true if status.nil?
      next if status.nil?
      sub.update(**status, proxyjudge_id: submission_id)
      ActionCable.server.broadcast("submission_#{sub.id}_overall", status.update(id: sub.id))
    end
    update_hash = submission_data.filter_map do |x|
      status = get_status_dict(x)
      sub = identified_submissions[x[:run_id]]
      next if sub.nil?
      result = true if status.nil?
      expected = {result: sub.result, score: sub.score, total_time: sub.total_time, total_memory: sub.total_memory}
      status.update(id: sub.id) if status && status != expected
    end
    Submission.import(
      update_hash.map {|x| x.update(compiler_id: -1, code_content_id: -1)},
      on_duplicate_key_update: [:result, :score, :total_time, :total_memory], validate: false)
    update_hash.each{ |x|
      ActionCable.server.broadcast("submission_#{x[:id]}_overall", x)
    }
    result
  end

  private

  def get_status_dict(status)
    verdict = status[:verdict]
    return nil if verdict.nil? || verdict.empty? || verdict.include?("ing")
    verdict = format_verdict(verdict)
    {
      result: verdict,
      score: verdict == 'AC' ? 100 : 0,
      total_time: status[:time]&.to_i || 0,
      total_memory: status[:memory]&.to_i || 0,
    }
  end

  def get_status_dict_from_detail(response)
    get_status_dict(DETAIL_REGEX.match(response))
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
