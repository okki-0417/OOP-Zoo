# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class ShowEnclosure < Action
        def call(params)
          profile = @container.enclosure_detail.call(params['id'])
          raise Application::Errors::EnclosureNotFound, "エリア #{params['id']} は存在しません" if profile.nil?

          [200, Serializer.enclosure(profile)]
        end
      end
    end
  end
end
