class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.with_advisory_lock(lock_name, options = {}, &block)
    # Natural namespacing of different model classes
    super("TIOJ_#{self.name}_#{lock_name}", options, &block)
  end
end
