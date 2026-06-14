# frozen_string_literal: true

require 'sinatra/base'
require 'json'

module Zoo
  module Presentation
    # HTTP(JSON)アダプタのルーター。各ルートを Web::* アクションに配送し、戻り値を JSON 化、
    # 例外を HTTP ステータスに翻訳する。処理は1ルート1アクション(Web::*)に置く。
    # アプリ層は CLI と共有のまま(Container 経由)。
    class Web < Sinatra::Base
      set :container, nil
      set :raise_errors, false
      set :show_exceptions, false
      set :host_authorization, { permitted_hosts: [] }

      helpers do
        def container
          settings.container ||= Zoo::Composition::Container.new
        end

        def dispatch(action_class)
          code, data = action_class.new(container: container).call(params)
          content_type :json
          status code
          data.to_json
        end

        def error_json(code)
          content_type :json
          status code
          { error: env['sinatra.error'].message }.to_json
        end
      end

      # 3つの輪の例外を HTTP ステータスへ翻訳する。
      error(Application::Errors::ApplicationError) { error_json(404) }
      error(Domain::Errors::DomainError) { error_json(422) }
      error(ArgumentError) { error_json(400) }

      post('/animals') { dispatch(AcquireAnimal) }
      get('/animals') { dispatch(ListAnimals) }
      get('/animals/:id') { dispatch(ShowAnimal) }
      post('/enclosures') { dispatch(AddEnclosure) }
      get('/enclosures') { dispatch(ListEnclosures) }
      post('/enclosures/:id/occupants') { dispatch(HouseAnimal) }
      post('/visitors') { dispatch(AdmitVisitors) }
      get('/report') { dispatch(Report) }
      post('/operate') { dispatch(OperateDay) }
    end
  end
end
