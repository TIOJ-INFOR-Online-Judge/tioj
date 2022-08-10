require 'active_record/connection_adapters/abstract_mysql_adapter'
module ActiveRecord::ConnectionAdapters
  ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter::NATIVE_DATABASE_TYPES[:datetime][:limit] = 6
end
