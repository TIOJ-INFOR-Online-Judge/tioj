ActiveAdmin.register User do
  permit_params do
    permitted = [
      :admin, :email, :nickname, :school, :gradyear, :name, :motto, :last_compiler_id,
      :password, :password_confirmation
    ]
    if params[:action] != 'create' && params[:user] && params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    if params[:action] == 'create'
      permitted += [:username]
    end
    permitted
  end

  index do
    selectable_column
    id_column
    column :username
    column :email
    column :nickname
    column :name
    column :admin
    column :created_at
    column :updated_at
    column :sign_in_count
    actions
  end

  show do
    attributes_table :id, *default_attribute_table_rows
  end

  preserve_default_filters!
  remove_filter :encrypted_password
  remove_filter :reset_password_token
  remove_filter :submissions
  remove_filter :posts
  remove_filter :comments
  remove_filter :articles
  remove_filter :contest_id
  remove_filter :contest_registrations
  remove_filter :registered_contests
  filter :id
  filter :username
  filter :nickname
  filter :name
  filter :admin
  filter :registered_contests_id, as: :numeric, label: 'Registered contest ID'

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end

    def create
      super
      resource.generate_random_avatar
      resource.save # errors would have already happened and rendered in super
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      if f.object.new_record?
        f.input :username
      else
        f.input :username, input_html: { disabled: true }
      end
      f.input :admin
      f.input :email
      f.input :nickname
      f.input :school
      f.input :gradyear
      f.input :name
      f.input :motto
      f.input :last_compiler
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end

end
