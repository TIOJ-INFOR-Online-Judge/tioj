class TestdataController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_problem, except: [:show]
  before_action :set_testdatum, only: [:show, :edit, :update, :destroy]
  before_action :set_testdata, only: [:batch_edit, :batch_update]
  helper_method :strip_uuid

  COMPRESS_THRESHOLD = 128 * 1024

  def index
    @testdata = @problem.testdata
  end

  def new
    @testdatum = @problem.testdata.build
  end

  def show
    if params[:type] == 'input'
      path = @testdatum.test_input
      name = @testdatum.test_input_identifier
      compressed = @testdatum.input_compressed
    elsif params[:type] == 'output'
      path = @testdatum.test_output
      name = @testdatum.test_output_identifier
      compressed = @testdatum.output_compressed
    else
      raise_not_found
    end
    name = strip_uuid(name)
    name = name + '.zst' if compressed
    send_file path.to_s, filename: name
  end

  def create

    testdata_errors = []
    print testdatum_params_list.size

    testdatum_params_list.each do |p|
      puts p
    end

    testdatum_params_list.each do |testdatum_params|
      @testdatum = @problem.testdata.build(testdatum_params.to_h)
      if not @testdatum.save
        testdata_errors << @testdatum.errors
      end
    end

    respond_to do |format|
      if testdata_errors.empty?
        format.html { redirect_to problem_testdata_path(@problem), notice: 'Testdatum was successfully created.' }
        #format.json { render action: 'show', status: :created, location: prob_testdata_path(@problem, @testdatum) }
      else
          format.html { render action: 'new' }
          format.json { render json: testdata_errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @testdatum.update(testdatum_params)
        format.html { redirect_to problem_testdata_path(@problem), notice: 'Testdatum was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @testdatum.errors, status: :unprocessable_entity }
      end
    end
  end

  def batch_edit
  end

  def batch_update
    params = batch_update_params
    prev = {}
    params_arr = @testdata.map.with_index do |td, index|
      now = params[:td][td.id.to_s]
      cur = now.except(:form_same_as_above)
      if index == 0 or now[:form_same_as_above].to_i == 0
        prev = cur
      end
      prev[:form_delete] = cur[:form_delete]
      [td.id, prev.clone]
    end
    orig_order_mp = @testdata.map(&:id).map.with_index.to_h
    to_delete = params_arr.filter{|x| x[1][:form_delete].to_i != 0}.map{|x| x[0]}
    params_arr = params_arr.filter{|x| x[1][:form_delete].to_i == 0}.sort_by{|x|
      [x[1][:position].to_i, orig_order_mp[x[0]]]
    }.map.with_index{|x, index|
      x[1][:position] = index
      [x[0], x[1]]
    }.to_h

    begin
      Testdatum.acts_as_list_no_update do
        Testdatum.transaction do
          td_map = @testdata.index_by(&:id)
          params_arr.each do |id, x|
            td_map[id].update!(x)
          end
          Testdatum.where(id: to_delete).delete_all
        end
      end
      respond_to do |format|
        format.html { redirect_to problem_testdata_path(@problem), notice: 'Testdata was successfully updated.' }
        format.json { head :no_content }
      end
    rescue ActiveRecord::RecordInvalid => invalid
      respond_to do |format|
        format.html { render action: 'batch_edit' }
        format.json { render json: invalid.record.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @testdatum.destroy
    respond_to do |format|
      if params[:index_all] == '1'
        format.html {redirect_to '/testdata' }
      else
        format.html { redirect_to problem_testdata_path(@problem) }
      end
      format.json { head :no_content }
    end
  end

  private
  def set_testdatum
    @testdatum = Testdatum.find(params[:id])
  end

  def set_testdata
    @testdata = @problem.testdata
  end

  def set_problem
    @problem = Problem.find(params[:problem_id])
  end

  def strip_uuid(x)
    x[0...-37]
  end

  def compress_file(f)
    Tempfile.create(binmode: true) do |tmpfile|
      File.open(f.path, 'rb') do |origfile|
        stream = Zstd::StreamingCompress.new(7)
        while (buffer = origfile.read(1024 * 1024)) do
          tmpfile.write(stream.compress(buffer))
        end
        tmpfile.write(stream.finish)
      end
      tmpfile.flush
      nsize = tmpfile.size
      tmpfile.close
      if nsize < f.size
        File.rename tmpfile.path, f.path
        return true
      end
    end
    false
  end

  def decompress_file(f)
    tmpfile = Tempfile.new(binmode: true)
    File.open(f, 'rb') do |origfile|
      stream = Zstd::StreamingDecompress.new
      while (buffer = origfile.read(1024 * 1024)) do
        tmpfile.write(stream.decompress(buffer))
      end
    end
    tmpfile.close
    tmpfile
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def testdatum_params_list
    new_params = params.require(:testdatum).permit(
      :problem_id,
      :time_limit,
      :rss_limit,
      :vss_limit,
      :output_limit,
      test_input_list:[],
      test_output_list:[],
    )

    test_input = new_params[:test_input_list].reject{ |item| item.is_a?(String)  }.select{ |item| item.original_filename.end_with?(".in")}
    test_output = new_params[:test_output_list].reject{ |item| item.is_a?(String) }.select{ |item| item.original_filename.end_with?(".out")}
    #print test_input.size
    #print test_output.size

    new_params.delete(:test_input_list)
    new_params.delete(:test_output_list)

    new_params_list = test_input.zip(test_output).map do |item1, item2|
      new_params.dup.tap do |params|
        params[:test_input] = item1
        params[:test_output] = item2

        if params[:test_input]
          params[:input_compressed] = false
          if params[:test_input].size >= COMPRESS_THRESHOLD
            params[:input_compressed] = compress_file(params[:test_input])
          end
        end
        if params[:test_output]
          params[:output_compressed] = false
          if params[:test_output].size >= COMPRESS_THRESHOLD
            params[:output_compressed] = compress_file(params[:test_output]) end
        end
      end
    end

    new_params_list
  end

  def testdatum_params
    new_params = params.require(:testdatum).permit(
      :problem_id,
      :test_input,
      :test_output,
      :time_limit,
      :rss_limit,
      :vss_limit,
      :output_limit,
    )
    if new_params[:test_input]
      new_params[:input_compressed] = false
      if new_params[:test_input].size >= COMPRESS_THRESHOLD
        new_params[:input_compressed] = compress_file(new_params[:test_input])
      end
    end
    if new_params[:test_output]
      new_params[:output_compressed] = false
      if new_params[:test_output].size >= COMPRESS_THRESHOLD
        new_params[:output_compressed] = compress_file(new_params[:test_output])
      end
    end
    new_params
  end

  def batch_update_params
    params.permit(td: [:time_limit, :vss_limit, :rss_limit, :output_limit, :position, :form_same_as_above, :form_delete])
  end
end
