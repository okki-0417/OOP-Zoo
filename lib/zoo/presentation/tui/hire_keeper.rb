# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class HireKeeper < Action
        def call
          name = @prompt.ask('飼育員名:')
          class_keys = @prompt.multi_select('専門の綱(複数可)', Domain::Taxonomy::TaxonClass::CLASSES.keys)

          command = Application::Commands::HireKeeperCommand.new(
            name: name,
            specialties: class_keys.map { |key| Domain::Taxonomy::TaxonClass.new(key) }
          )
          keeper = @container.hire_keeper.call(command)
          @output.puts "採用しました: #{keeper.name}"
        end
      end
    end
  end
end
