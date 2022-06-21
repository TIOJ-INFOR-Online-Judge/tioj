class FetchController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_key
  layout false

  def interlib
    @problem = Problem.find(params[:pid])
    @interlib = @problem.interlib.to_s + "\n"
    render text: @interlib
  end

  def sjcode
    @problem = Problem.find(params[:pid])
    @sjcode = @problem.sjcode.to_s
    render text: @sjcode
  end

  def code
    @submission = Submission.find(params[:sid])
    @code = @submission.code.to_s
    render text: @code
  end

  def testdata_meta
    @problem = Problem.find(params[:pid])
    @result = @problem.testdata.count.to_s + " "
    @problem.testdata.order(position: :asc).each do |t|
      @result += t.id.to_s + " "
      @result += t.updated_at.to_i.to_s + "\n"
    end
    render text: @result
  end

  def testdata_limit
    @problem = Problem.find(params[:pid])
    @result = ""
    @problem.testdata.order(position: :asc).includes(:limit).each do |t|
      @result += t.limit.time.to_s + " "
      @result += t.limit.memory.to_s + " "
      @result += t.limit.output.to_s + "\n"
    end
    render text: @result
  end

  def write_result
    @_result = params[:result]
    @submission = Submission.find(params[:sid])
    if @_result == "CE"
      @submission.update(:result => "CE", :score => 0)
    elsif @_result == "ER"
      @submission.update(:result => "ER", :score => 0)
    else
      update_verdict
    end
    render :nothing => true
  end

  def write_message
    @_message = params[:message]
    @submission = Submission.find(params[:sid])
    @submission.update(:message => @_message)
    #logger.info @_message
    render :nothing => true
  end

  def update_verdict
    #score
    @_result = @_result.split("/").each_slice(3).map.with_index { |res, id|
      {:submission_id => @submission.id, :position => id, :result => res[0],
       :time => res[1].to_i, :memory => res[2].to_i,
       :score => res[0] == 'AC' ? 100 : 0}
    }.select{|x| x[:result] != ''}
    SubmissionTask.import(@_result, on_duplicate_key_update: [:result, :time, :memory, :score])
    @problem = @submission.problem
    num_tasks = @problem.testdata.count
    @score = @problem.testdata_sets.map{|s|
      lst = td_list_to_arr(s.td_list, num_tasks)
      lst.size > 0 ? @_result.values_at(*lst).map{|x| x[:score]}.min * s.score : 100 * s.score
    }.sum / 100
    @score = [@score, BigDecimal('1e+12') - 1].min.round(6)
    @submission.update(:score => @score)

    #verdict
    if params[:status] == "OK"
      ttime = @_result.map{|i| i[:time]}.sum
      tmem = @_result.map{|i| i[:memory]}.max
      @result = @_result.map{|i| @v2i[i[:result]] ? @v2i[i[:result]] : 9}.max
      @submission.update(:result => @i2v[@result], :total_time => ttime, :total_memory => tmem)
    end
  end

  def testdata
    @testdata = Testdatum.find(params[:tid])
    if params[:input]
      @path = @testdata.test_input
    else
      @path = @testdata.test_output
    end
    send_file(@path.to_s)
  end

  def validating
    @submission = Submission.find(params[:sid])
    @submission.update(:result => "Validating")
    render :nothing => true
  end

  def submission
    Submission.transaction do
      @submission = Submission.lock.where("`result` = 'queued' AND `contest_id` IS NOT NULL").order('id').first
      if not @submission
        @submission = Submission.lock.where("`result` = 'queued'").order('id').first
      end
      if @submission
        @submission.update(:result => "Validating")
      end
    end
    #@submission = Submission.where("`result` = 'queued' AND `contest_id` IS NULL").order('id desc').first
    #if not @submission
    #  @submission = Submission.where("`result` = 'queued'").order('id desc').first
    #end
    if @submission
      @result = @submission.id.to_s
      @result += "\n"
      @result += @submission.problem_id.to_s
      @result += "\n"
      @result += @submission.problem.problem_type.to_s
      @result += "\n"
      @result += @submission.user_id.to_s
      @result += "\n"
      @result += @submission.compiler.name.to_s
      @result += "\n"
    else
      @result = "-1\n"
    end
    render text: @result
  end

private
  def authenticate_key
    if (not params[:key]) or params[:key] != Tioj::Application.config.fetch_key
      render :nothing => true
      return
    end
  end
end
