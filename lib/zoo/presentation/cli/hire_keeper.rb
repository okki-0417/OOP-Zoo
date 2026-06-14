# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class HireKeeper < Command
        def run(args)
          name, *class_keys = args
          raise ArgumentError, '使い方: hire-keeper NAME CLASS [CLASS...]' if name.nil? || class_keys.empty?

          specialties = class_keys.map { |key| Domain::Taxonomy::TaxonClass.new(key) }
          command = Application::Commands::HireKeeperCommand.new(name: name, specialties: specialties)
          keeper = @container.hire_keeper.call(command)
          @output.puts "採用しました（飼育員）: #{keeper.name}（id=#{keeper.id}）"
        end
      end
    end
  end
end
