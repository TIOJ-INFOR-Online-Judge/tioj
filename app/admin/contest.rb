ActiveAdmin.register Contest do

  index do
    selectable_column
    id_column
    column :title
    column :start_time
    column :end_time
    column :contest_type
    actions
  end

  preserve_default_filters!
  remove_filter :submissions
  remove_filter :contest_problem_joints
  remove_filter :problems
  filter :id

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
