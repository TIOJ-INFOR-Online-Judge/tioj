class UsernameConventionValidator < ActiveModel::EachValidator
  def validate_each(record, field, value)
    unless value.blank?
      if Rails.configuration.x.settings.dig(:unicode_username)
        record.errors.add field, "contains illegal characters" if /[\/]/.match(value)
      else
        record.errors.add field, "is not alphanumeric (letters, numbers, underscores or periods)" unless /^[a-zA-Z0-9._\-]+$/.match(value)
        record.errors.add field, "should start with a letter" unless /^[A-Za-z]/.match(value)
      end
      record.errors.add field, "is forbidden" if ['sign_in', 'sign_up'].include? value
      record.errors.add field, "should not be purely numeric" if /^[0-9]+$/.match(value)
    end
  end
end