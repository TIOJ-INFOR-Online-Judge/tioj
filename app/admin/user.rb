ActiveAdmin.register User do
  permit_params :email, :nickname, :admin, :avatar_url, :motto, :school, :gradyear, :name

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
    column :current_sign_in_at
    actions
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
