# frozen_string_literal: true

module Zoo
  module Application
    Result = Data.define(:service, :value, :error) do
      const_set(:SERVICES, %i[
        acquire_animal add_enclosure admit_visitors assign_keeper clean_enclosure conceive_animals
        deliver_animal discharge_keeper examine_animal feed_animal hire_keeper hire_veterinarian
        house_animal name_animal open_for_a_day operate_day release_animal rename_animal run_days
        set_admission_fee transfer_animal treat_animal
        animal_detail animal_list deceased_list enclosure_detail enclosure_list keeper_list
        operating_history population revenue threatened_species veterinarian_list zoo_report
        species_list food_list taxon_class_list
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
