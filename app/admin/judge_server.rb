ActiveAdmin.register JudgeServer do

  permit_params :name, :ip, :key

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :ip
      f.input :key
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
