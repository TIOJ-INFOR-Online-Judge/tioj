class TeamNameConventionValidator < ActiveModel::EachValidator
  include ValidateNameConcern

  def validate_each(record, field, value)
    validate_name(record, field, value, false)
  end
end