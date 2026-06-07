module ValidateNameConcern
  private

  def validate_name(record, field, value, is_username)
    return if value.blank?

    settings = Rails.configuration.x.settings.dig(is_username ? :username_settings : :team_name_settings)
    settings ||= {}

    min_length = settings[:min_length] || (is_username ? 3 : 1)
    max_length = settings[:max_length] || (is_username ? 20 : 50)
    record.errors.add field, "too short (minimum is #{min_length} characters)" if value.length < min_length
    record.errors.add field, "too long (maximum is #{max_length} characters)" if value.length > max_length

    allow_unicode = settings[:allow_unicode]
    if allow_unicode.nil?
      allow_unicode = Rails.configuration.x.settings.dig(:unicode_username)
      allow_unicode = true if allow_unicode.nil? && !is_username
    end
    if allow_unicode
      record.errors.add field, "contains illegal characters" if /[^[:print:]]/.match(value)
      record.errors.add field, "contains illegal characters" if /[\/]/.match(value) && is_username
    else
      record.errors.add field, "is not alphanumeric (letters, numbers, underscores or periods)" unless /^[a-zA-Z0-9._\-]+$/.match(value)
      record.errors.add field, "should start with a letter" unless /^[A-Za-z]/.match(value)
    end
    if is_username
      Rails.logger.fatal is_username.inspect
      record.errors.add field, "is forbidden" if ['sign_in', 'sign_up'].include? value
      record.errors.add field, "should not be purely numeric" if /^[0-9]+$/.match(value)
    end
  end
end