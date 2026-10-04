# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class ConceiveAnimalsCommand < CommandFactory
    target ::Zoo::Application::Commands::ConceiveAnimalsCommand

    defaults do |animals:, **|
      sire, dam = build_pair(::Zoo::Domain::SpeciesCatalog.lion)
      animals.save(sire)
      animals.save(dam)

      { sire_id: sire.id, dam_id: dam.id }
    end
  end
end
