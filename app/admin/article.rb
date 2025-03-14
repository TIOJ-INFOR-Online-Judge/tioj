ActiveAdmin.register Article do
  permit_params :title, :content, :era, :pinned, :category, :public
  includes :user

  index do
    selectable_column
    id_column
    column :title
    column :era
    column :user
    column :public
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :title
      f.input :content
      f.input :era
      f.input :pinned
      f.input :category
      f.input :public
    end
    f.actions
  end

  preserve_default_filters!
  remove_filter :attachments
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
