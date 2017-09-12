# encoding: utf-8

require "spec_helper"

module Backup
  RSpec.describe Database::InfluxDB do
    let(:model) { Model.new(:test_trigger, 'test label') }
    let(:db) { described_class.new(model) }

    before do
      allow(Utilities).to receive(:utility).with(:influxd).and_return('influxd')
      allow(Utilities).to receive(:utility).with(:tar).and_return('tar')
      allow(Utilities).to receive(:utility).with(:cat).and_return('cat')
    end

    describe '#initialize' do
      context 'when influxd_utility option is specified' do
        let(:db) do
          described_class.new(model) do |db|
            db.influxd_utility = '/path/to/influxd'
          end
        end

        it 'should use the given value' do
          expect(db.influxd_utility).to eq '/path/to/influxd'
        end
      end

      context 'when influxd_utility option is not specified' do
        it 'should find influxd utility' do
          expect(db.influxd_utility).to eq 'influxd'
        end
      end
    end # describe '#initialize'

    describe '#perform!' do
      let(:pipeline) { double }

      before do
        db.name = 'my_db'

        allow(Config).to receive(:tmp_path).and_return('/tmp')

        expect(Pipeline).to receive(:new).and_return(pipeline)

        allow(Dir).to receive(:mktmpdir).and_return('/tmp/abc123')
        expect(FileUtils).to receive(:remove_entry).with('/tmp/abc123')

        db.instance_variable_set(:@dump_path, '/dump/path')
        allow(db).to receive(:dump_filename).and_return('dump_filename')

        expect(db).to receive(:log!).with(:started).ordered
        expect(db).to receive(:prepare!).ordered
      end

      context 'when no compressor is configured' do
        before do
          expect(model).to receive(:compressor)
        end

        it 'should back up via influxd and not compress' do
          expect(db).to receive(:run).with("influxd backup -database 'my_db' '/tmp/abc123/my_db'").ordered

          expect(pipeline).to receive(:add).with("tar -cf - -C '/tmp/abc123' 'my_db'", [0]).ordered

          expect(pipeline).to receive(:<<).with("cat > '/dump/path/dump_filename.tar'").ordered

          expect(pipeline).to receive(:run).ordered
          expect(pipeline).to receive(:success?).and_return(true).ordered

          expect(db).to receive(:log!).with(:finished).ordered

          db.perform!
        end
      end

      context 'when a compressor is configured' do
        let(:compressor) { double }

        before do
          expect(model).to receive(:compressor).twice.and_return(compressor)
          expect(compressor).to receive(:compress_with).and_yield('gzip', '.gz')
        end

        it 'should back up via influx and compress' do
          expect(db).to receive(:run).with("influxd backup -database 'my_db' '/tmp/abc123/my_db'").ordered

          expect(pipeline).to receive(:add).with("tar -cf - -C '/tmp/abc123' 'my_db'", [0]).ordered

          expect(pipeline).to receive(:<<).with("gzip").ordered

          expect(pipeline).to receive(:<<).with("cat > '/dump/path/dump_filename.tar.gz'").ordered

          expect(pipeline).to receive(:run).ordered
          expect(pipeline).to receive(:success?).and_return(true).ordered

          expect(db).to receive(:log!).with(:finished).ordered

          db.perform!
        end
      end
    end # describe '#perform!'

  end
end
