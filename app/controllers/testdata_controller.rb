class TestdataController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_problem, except: [:show]
  before_action :set_testdatum, only: [:show, :edit, :update, :destroy]
  before_action :set_testdata, only: [:batch_edit, :batch_update]
  helper_method :strip_uuid

  COMPRESS_THRESHOLD = 128 * 1024
  TESTDATUM_LIMIT = 2 * 1024 * 1024 * 1024

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
    @testdatum = @problem.testdata.build(testdatum_params)

    respond_to do |format|
      if @testdatum.save
        format.html { redirect_to problem_testdata_path(@problem), notice: 'Testdatum was successfully created.' }
        format.json { head :no_content }
      else
        format.html { render action: 'new' }
        format.json { render json: @testdatum.errors, status: :unprocessable_entity }
      end
    end
  end

  def batch_new
    @testdata_errors = ActiveModel::Errors.new(self)
  end

  def batch_create
    @testdata_errors = ActiveModel::Errors.new(self)
    begin
      Dir.mktmpdir do |tmp_folder|
        checked_params, td_pair_dest = unzip_testdata(tmp_folder)
        td_pair_dest.each do |in_dest, out_dest|
          # generate testdata params
          testdatum_params = checked_params.dup
          File.open(in_dest) do |in_file|
            File.open(out_dest) do |out_file|
              testdatum_params[:test_input] = in_file
              testdatum_params[:test_output] = out_file
              testdatum = @problem.testdata.build(compressed_td_params(testdatum_params))
              unless testdatum.save
                testdatum.errors.full_messages.each do |msg|
                  @testdata_errors.add(:base, msg)
                end
              end
            end
          end
        end
      end
    rescue ArgumentError => e
      @testdata_errors.add(:base, e.message)
      respond_to do |format|
        format.html { render action: 'batch_new' }
        format.json { render json: e.message, status: :unprocessable_entity }
      end
      return
    rescue StandardError
      # invalid zip file
      @testdata_errors.add(:base, 'Invalid request')
      respond_to do |format|
        format.html { render action: 'batch_new' }
        format.json { render json: message, status: :unprocessable_entity }
      end
      return
    end

    respond_to do |format|
      if @testdata_errors.empty?
        format.html { redirect_to problem_testdata_path(@problem), notice: 'Testdatum was successfully created.' }
        format.json { head :no_content }
      else
        format.html { render action: 'batch_new' }
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

  def compressed_td_params(params)
    if params[:test_input]
      params[:input_compressed] = false
      if params[:test_input].size >= COMPRESS_THRESHOLD
        params[:input_compressed] = compress_file(params[:test_input])
      end
    end
    if params[:test_output]
      params[:output_compressed] = false
      if params[:test_output].size >= COMPRESS_THRESHOLD
        params[:output_compressed] = compress_file(params[:test_output])
      end
    end
    params
  end

  # Never trust parameters from the scary internet, only allow the white list through. 
  # and check if the file is a zip file
  def unzip_testdata(tmp_folder)
    checked_params = params.require(:testdatum).permit(
      :problem_id,
      :time_limit,
      :rss_limit,
      :vss_limit,
      :output_limit,
      :testdata_file_list,
      :testdata_pairs,
    )
    td_pairs = JSON.parse(checked_params[:testdata_pairs])
    unless td_pairs.is_a?(Array) and td_pairs.size <= 256 and td_pairs.all?{|x| x.is_a?(Array) and x.size == 2 and x.all?{|y| y.is_a?(String)}}
      raise ArgumentError.new("Invalid testdata pairs")
    end

    td_pair_dest = []
    Zip::File.open(checked_params[:testdata_file_list].path) do |zip|
      td_pairs.each do |infile, outfile|
        # check if the file exists
        in_entry = zip.find_entry(infile)
        out_entry = zip.find_entry(outfile)
        if in_entry.nil? or out_entry.nil?
          raise ArgumentError.new("File not found")
        end
        if in_entry.size + out_entry.size >= TESTDATUM_LIMIT
          raise ArgumentError.new("Individual testdata should not exceed 2 GiB")
        end
        in_dest = "#{tmp_folder}/#{in_entry.name}"
        out_dest = "#{tmp_folder}/#{out_entry.name}"
        in_entry.extract(in_dest)
        out_entry.extract(out_dest)
        td_pair_dest << [in_dest, out_dest]
      end
    end

    checked_params.delete(:testdata_file_list)
    checked_params.delete(:testdata_pairs)
    return checked_params, td_pair_dest
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
    compressed_td_params(new_params)
  end

  def batch_update_params
    params.permit(td: [:time_limit, :vss_limit, :rss_limit, :output_limit, :position, :form_same_as_above, :form_delete])
  end
end