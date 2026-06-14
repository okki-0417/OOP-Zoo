# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      HireKeeperCommand = Data.define(:name, :specialties) do
        def initialize(name:, specialties:)
          raise ArgumentError, 'name は必須です' if name.nil?
          raise ArgumentError, 'specialties は必須です' if specialties.nil?

          super(name: name, specialties: specialties)
        end
      end
    end
  end
end
