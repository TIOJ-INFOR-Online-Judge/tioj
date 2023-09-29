ActiveAdmin.register Problem do
  permit_params :name, :description, :source, :input, :output, :example_input, :example_output, :hint, :visible_state,
      :specjudge_type, :specjudge_compiler_id, :interlib_type, :sjcode, :interlib
      
  includes :specjudge_compiler

  index do
    selectable_column
    id_column
    column :name
    column :visible_state
    column :created_at
    column :updated_at
    actions
  end

  preserve_default_filters!
  remove_filter :contest_problem_joints
  remove_filter :submissions
  remove_filter :old_submissions
  remove_filter :ban_compilers
  remove_filter :contests
  remove_filter :sample_testdata
  remove_filter :posts
  remove_filter :testdata
  remove_filter :subtasks
  remove_filter :base_tags
  remove_filter :tag_taggings
  remove_filter :taggings
  remove_filter :tags
  remove_filter :solution_tag_taggings
  remove_filter :solution_tags
  filter :id
  filter :visible_state
  filter :specjudge_type
  filter :specjudge_compiler_id
  filter :interlib_type
  filter :tags_name, as: :string
  filter :solution_tags_name, as: :string

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
