ActiveAdmin.register Testdatum do
  includes :problem

  index do
    selectable_column
    id_column
    column :problem_id
    column :position
    column :created_at
    column :updated_at
    column :time_limit
    column :vss_limit
    column :rss_limit
    column :output_limit
    actions
  end

  preserve_default_filters!
  remove_filter :problem
  filter :id
  filter :problem_id

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
