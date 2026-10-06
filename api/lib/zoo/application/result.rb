# frozen_string_literal: true

module Zoo
  module Application
    Result = Data.define(:service, :value, :error) do
      const_set(:SERVICES, %i[
        acquire_animal add_enclosure admit_visitors assign_keeper clean_enclosure conceive_animals
        deliver_animal discharge_keeper enrich_enclosure examine_animal feed_animal hire_keeper hire_veterinarian
        house_animal make_rounds name_animal operate_day release_animal rename_animal run_days
        set_admission_fee transfer_animal treat_animal alert_list
      ].freeze)

      def self.capture(service)
        success(service, yield)
      rescue Errors::ApplicationError, Domain::Errors::DomainError => e
        failure(service, e)
      end

      def self.success(service, value)
        new(service: service, value: value, error: nil)
      end

      def self.failure(service, error)
        new(service: service, value: nil, error: error)
      end

      def initialize(service:, value:, error:)
        raise ArgumentError, "未知のサービスです: #{service.inspect}" unless self.class::SERVICES.include?(service)

        super
      end

      def success?
        error.nil?
      end

      def failure?
        !success?
      end
    end
  end
end
