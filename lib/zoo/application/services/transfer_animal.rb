# frozen_string_literal: true

module Zoo
  module Application
    module Services
      # 個体を移送先エリアへ移す。収容できない場合は admit が(副作用の前に)例外を
      # 上げるので、移送元からの release に進まず、個体は元エリアに残る。
      class TransferAnimal
        def initialize(enclosures:, animals:, unit_of_work:)
          @enclosures = enclosures
          @animals = animals
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            target = @enclosures.find(command.enclosure_id)
            raise Errors::EnclosureNotFound, "エリア #{command.enclosure_id} は存在しません" if target.nil?

            animal = @animals.find(command.animal_id)
            raise Errors::AnimalNotFound, "動物 #{command.animal_id} は存在しません" if animal.nil?

            current = @enclosures.all.find { |enclosure| enclosure.houses?(animal) }

            target.admit(animal)
            current&.release(animal)
            @enclosures.save(target)
            @enclosures.save(current) if current
            target
          end
        end
      end
    end
  end
end
