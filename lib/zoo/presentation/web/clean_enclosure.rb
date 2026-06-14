# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class CleanEnclosure < Action
        def call(params)
          command = build_command(params)
          @container.clean_enclosure.call(command)
          [200, Serializer.enclosure(@container.enclosure_detail.call(params['id']))]
        end

        private

        def build_command(params)
          attrs = { keeper_id: params['keeper_id'], enclosure_id: params['id'] }
          attrs[:amount] = Integer(params['amount']) if params['amount']
          Application::Commands::CleanEnclosureCommand.new(**attrs)
        end
      end
    end
  end
end
