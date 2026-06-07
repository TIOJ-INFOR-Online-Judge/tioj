module RansackPatch
  def ransackable_attributes(auth_object = nil)
    column_names + _ransackers.keys
  end

  def ransackable_associations(auth_object = nil)
    reflect_on_all_associations.map { |a| a.name.to_s } + _ransackers.keys
  end
end

ActiveSupport.on_load(:active_record) do
  extend RansackPatch
end
