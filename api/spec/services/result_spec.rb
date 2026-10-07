# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::Result do
  describe '.success' do
    it 'success(:acquire_animal, 42) は service=:acquire_animal・value=42・error=nil を持つこと' do
      result = described_class.success(:acquire_animal, 42)

      expect(result).to have_attributes(service: :acquire_animal, value: 42, error: nil)
    end

    it 'success(...) は success?=true・failure?=false になること' do
      result = described_class.success(:acquire_animal, 42)

      expect(result).to be_success
      expect(result).not_to be_failure
    end
  end

  describe '.failure' do
    it 'failure(:feed_animal, error) は value=nil・error=渡した例外 を持つこと' do
      error = Services::Errors::AnimalNotFound.new('missing')
      result = described_class.failure(:feed_animal, error)

      expect(result).to have_attributes(service: :feed_animal, value: nil, error: error)
    end

    it 'failure(...) は success?=false・failure?=true になること' do
      result = described_class.failure(:feed_animal, Services::Errors::AnimalNotFound.new('missing'))

      expect(result).not_to be_success
      expect(result).to be_failure
    end
  end

  describe '.capture' do
    it 'ブロックが :ok を返すと success(value: :ok) になること' do
      result = described_class.capture(:admit_visitors) { :ok }

      expect(result).to have_attributes(service: :admit_visitors, value: :ok, error: nil)
    end

    it 'ブロックが ApplicationError(AnimalNotFound) を投げると failure(error: その例外) になること' do
      error = Services::Errors::AnimalNotFound.new('missing')
      result = described_class.capture(:feed_animal) { raise error }

      expect(result).to be_failure
      expect(result.error).to be(error)
    end

    it 'ブロックが DomainError(CapacityExceeded) を投げると failure(error: その例外) になること' do
      result = described_class.capture(:feed_animal) { raise Errors::CapacityExceeded, 'full' }

      expect(result).to be_failure
      expect(result.error).to be_a(Errors::CapacityExceeded)
    end

    it 'ブロックが ArgumentError を投げると包まずにそのまま伝播すること' do
      expect { described_class.capture(:run_days) { raise ArgumentError, 'bad' } }
        .to raise_error(ArgumentError, 'bad')
    end
  end

  describe '.new' do
    it 'SERVICES にない service=:typo を渡すと「未知のサービスです」の ArgumentError になること' do
      expect { described_class.success(:typo, 1) }
        .to raise_error(ArgumentError, /未知のサービスです: :typo/)
    end

    it 'service を文字列 "acquire_animal" で渡すと ArgumentError になること' do
      expect { described_class.success('acquire_animal', 1) }.to raise_error(ArgumentError)
    end
  end

  describe '::SERVICES' do
    it 'Application::Services 配下のサービスクラス名(snake_case)と同じ集合であること' do
      services = (Services.constants - %i[Result]).select { |name| Services.const_get(name).is_a?(Class) }

      expect(described_class::SERVICES).to match_array(services.map { |name| name.to_s.underscore.to_sym })
    end
  end
end
