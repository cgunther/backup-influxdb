require "backup"
require "backup/influxdb/version"

module Backup
  module Config
    class DSL
      get_or_create_empty_module(DSL, 'InfluxDB')
    end
  end

  module Database
    autoload :InfluxDB, File.join(File.dirname(__FILE__), 'backup/database/influxdb')
  end
end
