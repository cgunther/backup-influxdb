# encoding: utf-8

module Backup
  module Database
    class InfluxDB < Base

      ##
      # Name of the database that needs to get dumped.
      attr_accessor :name

      ##
      # Path to sqlite utility (optional)
      attr_accessor :influxd_utility

      ##
      # Creates a new instance of the Influx adapter object
      def initialize(model, database_id = nil, &block)
        super
        instance_eval(&block) if block_given?

        @influxd_utility ||= utility(:influxd)
      end

      ##
      # Performs the dump using influxd
      #
      # This will be stored in the final backup package as
      #   <trigger>/databases/InfluxDB[-<database_id>][.gz]
      def perform!
        super

        # path = File.join(Config.tmp_path, model.trigger, database_name)
        path = Dir.mktmpdir

        run("#{influxd_utility} backup -database '#{name}' '#{path}/#{name}'")

        pipeline = Pipeline.new
        pipeline.add(
          "#{utility(:tar)} -cf - -C '#{path}' '#{name}'",
          tar_success_codes
        )

        extension = "tar"
        if model.compressor
          model.compressor.compress_with do |command, ext|
            pipeline << command
            extension << ext
          end
        end

        pipeline << "#{utility(:cat)} > '#{File.join(dump_path, "#{dump_filename}.#{extension}")}'"
        pipeline.run

        if pipeline.success?
          FileUtils.remove_entry path

          log!(:finished)
        else
          raise Error, "Dump Failed!\n" + pipeline.error_messages
        end
      end

      private

      def tar_success_codes
        gnu_tar? ? [0, 1] : [0]
      end

    end
  end
end
