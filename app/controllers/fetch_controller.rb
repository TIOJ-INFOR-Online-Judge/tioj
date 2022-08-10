class FetchController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_key
  layout false

  def testdata
    @testdata = Testdatum.find(params[:tid])
    if params[:input]
      @path = @testdata.test_input
    else
      @path = @testdata.test_output
    end
    send_file(@path.to_s)
  end

private
  def authenticate_key
    if not params[:key]
      head :unauthorized
      return
    end
    @judge = JudgeServer.find_by(key: params[:key])
    if not @judge or (not (@judge.ip || "").empty? and @judge.ip != request.remote_ip)
      head :unauthorized
      return
    end
  end
end
