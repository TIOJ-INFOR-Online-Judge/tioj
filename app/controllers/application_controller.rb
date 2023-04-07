class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :store_location
  before_action :set_verdict_hash
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_anno
  before_action :set_layout
  mattr_accessor :verdict
  mattr_accessor :v2i
  mattr_accessor :i2v

  @@verdict = {
    "AC" => "Accepted",
    "WA" => "Wrong Answer",
    "TLE" => "Time Limit Exceeded",
    "MLE" => "Memory Limit Exceeded",
    "OLE" => "Output Limit Exceeded",
    "RE" => "Runtime Error",
    "SIG" => "Runtime Error (killed by signal)",
    "EE" => "Execution Error",
    "CE" => "Compilation Error",
    "CLE" => "Compilation Limit Exceeded",
    "ER" => "Judge Compilation Error",
    "JE" => "Judge Error",
    "queued" => "Waiting for judge server",
    "received" => "Queued in judge server",
    "Validating" => "Validating",
  }
  @@v2i = {
    "AC" => 0,
    "WA" => 1,
    "TLE" => 2,
    "MLE" => 3,
    "OLE" => 4,
    "RE" => 5,
    "SIG" => 6,
    "EE" => 7,
    "CE" => 8,
    "CLE" => 9,
    "ER" => 10,
    "JE" => 11,
  }
  @@i2v = @@v2i.map{|x, y| [y, x]}.to_h

  def set_verdict_hash
    @verdict = @@verdict
    @v2i = @@v2i
    @i2v = @@i2v
  end

  def store_location
    if (request.fullpath != "/users/sign_in" &&
        request.fullpath != "/users/sign_out" &&
        request.fullpath != "/users/sign_up" &&
        !request.xhr?)
      session[:previous_url] = request.fullpath
    end
  end
  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

protected
  def authenticate_admin!
    authenticate_user!
    if not current_user.admin?
      flash[:alert] = 'Insufficient User Permissions.'
      redirect_to action:'index'
      return
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(:school, :gradyear, :name, :email, :nickname, :username, :password, :password_confirmation, :remember_me)
    end
    devise_parameter_sanitizer.permit(:sign_in) do |u|
      u.permit(:login, :username, :email, :password, :remember_me)
    end
    devise_parameter_sanitizer.permit(:account_update) do |u|
      u.permit(:school, :gradyear, :name, :avatar, :avatar_cache, :motto, :email, :nickname, :password, :password_confirmation, :current_password)
    end
  end

  def set_layout
    if /\/contests\/[0-9]+/.match(request.fullpath)
      @layout = :contest
    else
      @layout = :application
    end
  end

  def set_contest_layout
    @layout.to_s
  end

  def set_anno
    contest_param = controller_name == 'contests' ? params[:id] : params[:contest_id]
    contest_id = contest_param && contest_param.to_i
    @annos = Announcement.where(contest_id: contest_id).order(:id).all.to_a
  end

  def get_sorted_user(limit = nil)
    attributes = [
      "users.*",
      "COUNT(DISTINCT CASE WHEN s.result = 'AC' THEN s.problem_id END) ac",
      "COUNT(DISTINCT CASE WHEN s.result = 'AC' THEN s.id END) acsub",
      "COUNT(s.id) sub",
      "COUNT(DISTINCT CASE WHEN s.result = 'AC' THEN s.id END) / COUNT(s.id) acratio",
    ]
    query = User.select(*attributes)
        .joins("LEFT JOIN submissions s ON s.user_id = users.id AND s.contest_id IS NULL")
        .group(:id).order('ac DESC', 'acratio DESC', 'sub DESC', :id)
    if limit
      query = query.limit(limit)
    end
    query.to_a
  end

  def reduce_td_list(str, sz)
    TestdataSet.td_list_str_to_arr(str, sz).chunk_while{|x, y|
      x + 1 == y
    }.map{|x|
      x.size == 1 ? x[0].to_s : x[0].to_s + '-' + x[-1].to_s
    }.join(',')
  end

  def inverse_td_list(prob)
    sz = prob.testdata.count
    prob.testdata_sets.map.with_index{|x, i| x.td_list_arr(sz).map{|y| [y, i]}}
        .flatten(1).group_by(&:first).map{|x, y| [x, y.map(&:last)]}.to_h
  end

  def shellsplit_safe(line)
    ApplicationController.shellsplit_safe(line)
  end

  def raise_not_found
    raise ActionController::RoutingError.new('')
  end

  public

  def self.shellsplit_safe(line)
    # adapted from shellwords library
    return [] if not line
    words = []
    field = String.new
    line.scan(/\G\s*(?>([^\s\\\'\"]+)|'([^\']*)'|"((?:[^\"\\]|\\.)*)"|(\\.?)|(\S))(\s|\z)?/m) do
      |word, sq, dq, esc, garbage, sep|
      field << (word || sq || (dq && dq.gsub(/\\([$`"\\\n])/, '\\1')) || esc.gsub(/\\(.)/, '\\1')) if not garbage
      if sep
        words << field
        field = String.new
      end
    end
    words
  end
end
