# frozen_string_literal: true

require 'sinatra/base'
require 'json'

module Zoo
  module Presentation
    # HTTP(JSON)アダプタのルーター。各ルートを Web::* アクションに配送し、戻り値を JSON 化、
    # 例外を HTTP ステータスに翻訳する。処理は1ルート1アクション(Web::*)に置く。
    # アプリ層は CLI/TUI と共有のまま(Container 経由)。
    class Web < Sinatra::Base
      set :container, nil
      set :raise_errors, false
      set :show_exceptions, false
      set :host_authorization, { permitted_hosts: [] }

      # 開発時はフロント(Vite dev server)が別オリジンになるため CORS を許可する。
      before do
        headers 'Access-Control-Allow-Origin' => '*',
                'Access-Control-Allow-Methods' => 'GET, POST, PATCH, DELETE, OPTIONS',
                'Access-Control-Allow-Headers' => 'Content-Type'
      end

      options('*') { 200 }

      helpers do
        def container
          settings.container ||= Zoo::Composition::Container.new
        end

        # ルート/クエリのパラメータに JSON ボディをマージする。フロントは JSON ボディで送る。
        def request_params
          return params unless request.media_type == 'application/json' && request.content_length.to_i.positive?

          body = JSON.parse(request.body.read)
          request.body.rewind
          (body.is_a?(Hash) ? body : {}).merge(params)
        end

        def dispatch(action_class)
          code, data = action_class.new(container: container).call(request_params)
          content_type :json
          status code
          data.to_json
        end

        def error_json(code)
          error = env['sinatra.error']
          content_type :json
          status code
          { error: { code: error.class.name.split('::').last, message: error.message } }.to_json
        end
      end

      # 3つの輪の例外を HTTP ステータスへ翻訳する。
      error(Application::Errors::ApplicationError) { error_json(404) }
      error(Domain::Errors::DomainError) { error_json(422) }
      error(ArgumentError) { error_json(400) }

      # --- 参照データ(選択肢の正はドメインのカタログ) ---
      get('/species') { dispatch(ListSpecies) }
      get('/foods') { dispatch(ListFoods) }
      get('/taxon-classes') { dispatch(ListTaxonClasses) }

      # --- 動物 ---
      get('/animals') { dispatch(ListAnimals) }
      post('/animals') { dispatch(AcquireAnimal) }
      get('/animals/:id') { dispatch(ShowAnimal) }
      patch('/animals/:id/name') { dispatch(RenameAnimal) }
      post('/animals/:id/feedings') { dispatch(FeedAnimal) }
      post('/animals/:id/treatments') { dispatch(TreatAnimal) }
      post('/animals/:id/examinations') { dispatch(ExamineAnimal) }
      post('/animals/:id/transfer') { dispatch(TransferAnimal) }

      # --- 飼育エリア ---
      get('/enclosures') { dispatch(ListEnclosures) }
      post('/enclosures') { dispatch(AddEnclosure) }
      get('/enclosures/:id') { dispatch(ShowEnclosure) }
      post('/enclosures/:id/occupants') { dispatch(HouseAnimal) }
      delete('/enclosures/:id/occupants/:animal_id') { dispatch(ReleaseAnimal) }
      post('/enclosures/:id/cleanings') { dispatch(CleanEnclosure) }

      # --- 繁殖 ---
      post('/breedings') { dispatch(BreedAnimals) }

      # --- スタッフ ---
      get('/keepers') { dispatch(ListKeepers) }
      post('/keepers') { dispatch(HireKeeper) }
      get('/veterinarians') { dispatch(ListVeterinarians) }
      post('/veterinarians') { dispatch(HireVeterinarian) }

      # --- 経営・運営 ---
      get('/report') { dispatch(Report) }
      get('/deceased') { dispatch(ListDeceased) }
      get('/threatened') { dispatch(ListThreatened) }
      post('/visitors') { dispatch(AdmitVisitors) }
      patch('/admission-fee') { dispatch(SetAdmissionFee) }
      post('/operate') { dispatch(OperateDay) }
      post('/run-days') { dispatch(RunDays) }
    end
  end
end
