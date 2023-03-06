class UsernameConventionValidator < ActiveModel::EachValidator
  def validate_each(record, field, value)
    unless value.blank?
      unless Rails.configuration.x.settings.dig(:unicode_username)
        record.errors.add field, "is not alphanumeric (letters, numbers, underscores or periods)" unless value =~ /^[[:alnum:]._-]+$/
        record.errors.add field, "should start with a letter" unless value[0] =~ /[A-Za-z]/
        record.errors.add field, "contains illegal characters" unless value.ascii_only?
      end
      record.errors.add field, "is forbidden" if ['sign_in', 'sign_up'].include? value
      record.errors.add field, "should not be purely numeric" if value =~ /^[0-9]+$/
    end
  end
end