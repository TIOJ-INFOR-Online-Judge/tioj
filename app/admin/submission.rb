ActiveAdmin.register Submission do
  permit_params :result, :score, :total_time, :total_memory, :message
  includes :compiler
  includes :code_content
  includes :user

  controller do
    actions :all, :except => [:create, :new]
  end

  index do
    selectable_column
    column :id do |t|
      link_to t.id, admin_submission_path(t)
    end
    column :problem_id
    column :user
    column :contest_id
    column :compiler
    column :result
    column :score
    actions
  end

  show do
    attributes_table do
      default_attribute_table_rows.each do |field|
        row field
      end
      row('Code') { |x| x.code_content.code_utf8 }
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :result
      f.input :score
      f.input :total_time
      f.input :total_memory
    end
    f.actions
  end

  preserve_default_filters!
  remove_filter :old_submission
  remove_filter :submission_testdata_results
  remove_filter :submission_subtask_result
  remove_filter :problem
  remove_filter :user
  remove_filter :code_content
  filter :problem_id
  filter :user_id
  filter :contest_id
  filter :code_content_code, as: :string

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
