class ContestRegistrationsController < InheritedResources::Base
  actions :index, :create, :new, :destroy
  before_action :authenticate_admin!
  layout :set_contest_layout

  class CreateForm
    include ActiveModel::Model

    attr_accessor :num_start, :num_end, :username_format, :nickname_format, :password_length, :account_file, :avatar
    attr_accessor :account_table, :avatar_dir, :avatar_map, :n_start, :n_end

    validates_numericality_of :num_start, greater_than: 0, less_than_or_equal_to: 1024
    validates_numericality_of :num_end, greater_than: 0, less_than_or_equal_to: 1024
    validates_numericality_of :num_end, greater_than_or_equal_to: :num_start
    validates_presence_of :username_format
    validates_presence_of :nickname_format
    validates_numericality_of :password_length, greater_than_or_equal_to: 4, less_than_or_equal_to: 32

    validates_each :username_format, :nickname_format do |record, attr, value|
      next if record.account_file
      begin
        num_start = record.num_start.to_i
        num_end = record.num_end.to_i
        if (num_start..num_end).map{|x| value % x}.uniq.size != num_end - num_start + 1
          record.errors.add(attr, 'produces duplicate values')
          return
        end
        record.n_start = num_start
        record.n_end = num_end
      rescue ArgumentError
        record.errors.add(attr, 'is not a valid format string')
      end
    end

    validate :validate_and_generate_account_data
    validate :validate_avatar

    CHARSET = '23456789abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ'.chars
    def validate_and_generate_account_data
      if account_file
        begin
          csv = CSV.parse(account_file.read, headers: true, header_converters: :downcase)
        rescue
          errors.add(:account_file, 'is not a valid CSV file')
          return
        end
        unless (['username', 'nickname', 'password'] - csv.headers).empty?
          errors.add(:account_file, 'does not have the required columns')
          return
        end
        @account_table = csv.map {|x|
          [x['username'], x['nickname'], x['password']]
        }
      else
        return unless @n_start
        @account_table = (@n_start..@n_end).map {|x|
          [username_format % x, nickname_format % x, CHARSET.sample(password_length.to_i, random: SecureRandom).join]
        }
      end
    end

    def validate_avatar
      return unless avatar && @account_table
      if avatar.size > 32.megabytes
        errors.add(:avatar, 'should not exceed 32 MiB')
      end
      begin
        img = MiniMagick::Image.read(avatar).destroy!
        return
      rescue MiniMagick::Invalid, MiniMagick::Error
      end
      # read as image failed; try zip
      tmpdir = Dir.mktmpdir
      basename = ''
      begin
        users = @account_table.map {|x| x[0]}.to_set
        current_mp = {}
        Zip::File.open(avatar) do |zip_file|
          zip_file.each do |f|
            basename = f.name.sub(/\.[^.]+$/, '')
            next if basename.include?('/') || !users.include?(basename) || current_mp.include?(basename)
            fpath = File.join(tmpdir, f.name)
            zip_file.extract(f, fpath)
            current_mp[basename] = f.name
            MiniMagick::Image.open(fpath).destroy!
          end
        end
        unless (users - current_mp.keys.to_set).empty?
          err_str = (users - current_mp.keys.to_set).join(', ')
          errors.add(:avatar, "does not contain images for #{err_str}")
          return
        end
        @avatar_dir = tmpdir
        @avatar_map = current_mp
      rescue MiniMagick::Invalid, MiniMagick::Error
        errors.add(:avatar, "contains invalid image for #{basename}")
      rescue Zip::Error
        errors.add(:avatar, 'is not an image or a valid zip file')
      ensure
        FileUtils.remove_dir(tmpdir) unless @avatar_dir
      end
    end
  end

  def create
    @form = CreateForm.new(new_params)
    if !@form.valid?
      render action: 'new'
      return
    end
    begin
      # TODO: create users
    ensure
      FileUtils.remove_dir(@form.avatar_dir) if @form.avatar_dir
    end
    redirect_to contest_contest_registrations_path(), notice: 'Contest users was successfully created.'
  end

  def new
    @form = CreateForm.new(num_start: 1, num_end: 10, password_length: 6)
    super
  end

  def index
    registrations = @contest.contest_registrations.includes(:user)
    groups = registrations.group_by{|x| x.approved ? (x.user.type == 'User' ? 1 : 0) : -1}
    @contest_users = groups[0]
    @registered_users = groups[1]
    @unapproved_users = groups[-1]
  end

 private

  def new_params
    params.require(:contest_registrations_controller_create_form).permit(
      :num_start, :num_end, :username_format, :nickname_format, :password_length, :account_file, :avatar
    )
  end
end
