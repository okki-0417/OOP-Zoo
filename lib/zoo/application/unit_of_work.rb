# frozen_string_literal: true

module Zoo
  module Application
    module UnitOfWork
      def run
        raise NotImplementedError, "#{self.class}#run を実装してください"
      end
    end
  end
end
