# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      StaffRef = Data.define(:id, :name) do
        def self.of(member)
          new(id: member.id.to_s, name: member.name)
        end
      end
    end
  end
end
