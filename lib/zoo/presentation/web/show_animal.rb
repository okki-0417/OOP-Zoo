# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class ShowAnimal < Action
        def call(params)
          profile = @container.animal_detail.call(params['id'])
          raise Application::Errors::AnimalNotFound, "動物 #{params['id']} は存在しません" if profile.nil?

          [200, profile.to_h]
        end
      end
    end
  end
end
