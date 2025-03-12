# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Thermal do
  before do
    hide_const('Rails') if defined?(Rails)
  end

  after do
    described_class.tmp_dir = nil
  end

  let(:stub_rails) do
    rails = double('Rails') # rubocop:disable RSpec/VerifiedDoubles
    allow(rails).to receive(:root).and_return(Pathname.new('/a/b/c'))
    stub_const('Rails', rails)
  end

  describe '.tmp_path' do
    before do
      allow(described_class).to receive(:gem_root).and_return(Pathname.new('/d/e/f'))
    end

    context 'when .tmp_dir set' do
      before do
        stub_rails
        described_class.tmp_dir = '/h/i/j'
      end

      it do
        dir = '/h/i/j'
        expect(FileUtils).to receive(:mkdir_p).with(dir)
        expect(described_class.tmp_path('qux.png')).to eq(Pathname.new(dir).join('qux.png'))
      end
    end

    context 'when Rails defined' do
      before { stub_rails }

      it do
        dir = '/a/b/c/tmp/thermal'
        expect(FileUtils).to receive(:mkdir_p).with(dir)
        expect(described_class.tmp_path('qux.png')).to eq(Pathname.new('/a/b/c/tmp/thermal/qux.png'))
      end

      it do
        dir = '/a/b/c/tmp/thermal/baz'
        expect(FileUtils).to receive(:mkdir_p).with(dir)
        expect(described_class.tmp_path('baz/qux.png')).to eq(Pathname.new('/a/b/c/tmp/thermal/baz/qux.png'))
      end
    end

    context 'when Rails not defined' do
      it do
        msg = 'Must set Thermal.tmp_dir'
        expect { described_class.tmp_path('qux.png') }.to raise_error(RuntimeError, msg)
      end
    end
  end

  describe '.tmp_dir=' do
    context 'when relative path' do
      it do
        msg = 'Thermal.tmp_dir must be an absolute path'
        expect { described_class.tmp_dir = 'foo/bar' }.to raise_error(ArgumentError, msg)
      end
    end

    context 'when absolute path' do
      it do
        described_class.tmp_dir = '/foo/bar'
        expect(described_class.tmp_dir).to eq(Pathname.new('/foo/bar'))
      end
    end
  end

  describe '.app_root' do
    context 'when Rails defined' do
      before { stub_rails }

      it { expect(described_class.app_root).to eq Pathname.new('/a/b/c') }
    end

    context 'when Rails not defined' do
      it { expect(described_class.app_root).to be_nil }
    end
  end
end
