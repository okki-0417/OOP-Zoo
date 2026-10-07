# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations do
  def execute(query)
    OopZooSchema.execute(query).to_h
  end

  def stub_service(use_case, result)
    service_class = Services.const_get(use_case.to_s.camelize)
    allow(service_class).to receive(:new).and_return(instance_double(service_class, call: result))
    service_class
  end

  describe 'BaseMutation の応答' do
    let(:lion) { build_adult(SpeciesCatalog.lion, name: 'レオ') }

    it 'サービスが success(value: レオ) を返すと、data.renameAnimal にその動物の name "レオ" が出ること' do
      stub_service(:rename_animal, Services::Result.success(:rename_animal, lion))

      response = execute('mutation { renameAnimal(animalId: "a1", newName: "レオ") { name } }')

      expect(response).to eq('data' => { 'renameAnimal' => { 'name' => 'レオ' } })
    end

    it "サービスが failure(AnimalNotFound '動物 a1 は存在しません') を返すと、data が null で errors[0] に message と extensions.code 'AnimalNotFound' が出ること" do
      error = Services::Errors::AnimalNotFound.new('動物 a1 は存在しません')
      stub_service(:rename_animal, Services::Result.failure(:rename_animal, error))

      response = execute('mutation { renameAnimal(animalId: "a1", newName: "レオ") { name } }')

      expect(response['data']).to be_nil
      expect(response['errors'].first).to include(
        'message' => '動物 a1 は存在しません', 'extensions' => { 'code' => 'AnimalNotFound' }
      )
    end

    it "サービスが failure(DomainError の CapacityExceeded) を返すと、extensions.code が 'CapacityExceeded' になること" do
      error = Errors::CapacityExceeded.new('満員です')
      stub_service(:rename_animal, Services::Result.failure(:rename_animal, error))

      response = execute('mutation { renameAnimal(animalId: "a1", newName: "レオ") { name } }')

      expect(response['errors'].first['extensions']).to eq('code' => 'CapacityExceeded')
    end

    it "Command が ArgumentError を投げる runDays(days: 0) は、サービスを呼ばずに extensions.code 'InvalidArgument' になること" do
      allow(Services::RunDays).to receive(:new)

      response = execute('mutation { runDays(days: 0) { days } }')

      expect(Services::RunDays).not_to have_received(:new)
      expect(response['errors'].first).to include(
        'message' => 'days は1以上でなければなりません', 'extensions' => { 'code' => 'InvalidArgument' }
      )
    end
  end

  describe 'モデルを直接呼ぶ mutation' do
    let(:hill) { create_enclosure(name: 'ライオンの丘') }
    let(:lion) { build_adult(SpeciesCatalog.lion, name: 'レオ').tap(&:save!) }

    it 'houseAnimal(enclosureId: 丘, animalId: レオ) は丘を返し、レオが丘に収容されること' do
      response = execute(%(mutation { houseAnimal(enclosureId: "#{hill.id}", animalId: "#{lion.id}") { name } }))

      expect(response).to eq('data' => { 'houseAnimal' => { 'name' => 'ライオンの丘' } })
      expect(lion.reload.enclosure).to eq(hill)
    end

    it 'transferAnimal(animalId: レオ, enclosureId: 草原) はレオを返し、レオが草原に移ること' do
      lion.move_to(hill).save!
      meadow = create_enclosure(name: '草原')

      response = execute(%(mutation { transferAnimal(animalId: "#{lion.id}", enclosureId: "#{meadow.id}") { name } }))

      expect(response).to eq('data' => { 'transferAnimal' => { 'name' => 'レオ' } })
      expect(lion.reload.enclosure).to eq(meadow)
    end

    it 'releaseAnimal(animalId: 丘にいるレオ) はレオを返し、レオがどのエリアにもいなくなること' do
      lion.move_to(hill).save!

      response = execute(%(mutation { releaseAnimal(animalId: "#{lion.id}") { name } }))

      expect(response).to eq('data' => { 'releaseAnimal' => { 'name' => 'レオ' } })
      expect(lion.reload.enclosure).to be_nil
    end
  end

  describe 'BaseMutation のエラー変換' do
    it "存在しない animalId: \"0\" を渡すと、errors[0] が message '動物 0 は存在しません'・extensions.code 'AnimalNotFound' になること" do
      response = execute('mutation { releaseAnimal(animalId: "0") { name } }')

      expect(response['data']).to be_nil
      expect(response['errors'].first).to include(
        'message' => '動物 0 は存在しません', 'extensions' => { 'code' => 'AnimalNotFound' }
      )
    end

    it "ドメインのルール違反(定員1の満員エリアへの収容)は extensions.code 'HousingNotAllowed' になり、収容は保存されないこと" do
      full = create_enclosure(name: '小屋', capacity: 1)
      build_adult(SpeciesCatalog.lion, name: '先住').move_to(full).save!
      lion = build_adult(SpeciesCatalog.lion, name: 'レオ').tap(&:save!)

      response = execute(%(mutation { houseAnimal(enclosureId: "#{full.id}", animalId: "#{lion.id}") { name } }))

      expect(response['errors'].first['extensions']).to eq('code' => 'HousingNotAllowed')
      expect(lion.reload.enclosure).to be_nil
    end
  end

  describe '引数からコマンドへの受け渡し' do
    {
      'acquireAnimal(speciesCode: "lion", name: "レオ", sex: MALE)' =>
        [:acquire_animal, Services::Commands::AcquireAnimalCommand, { species_code: 'lion', name: 'レオ', sex: :male }],
      'renameAnimal(animalId: "a1", newName: "シンバ")' =>
        [:rename_animal, Services::Commands::RenameAnimalCommand, { animal_id: 'a1', new_name: 'シンバ' }],
      'feedAnimal(animalId: "a1", keeperId: "k1", foodCode: "horse_meat")' =>
        [:feed_animal, Services::Commands::FeedAnimalCommand, { animal_id: 'a1', keeper_id: 'k1', food_code: 'horse_meat' }],
      'treatAnimal(animalId: "a1", veterinarianId: "v1")' =>
        [:treat_animal, Services::Commands::TreatAnimalCommand, { animal_id: 'a1', veterinarian_id: 'v1' }],
      'examineAnimal(animalId: "a1", veterinarianId: "v1")' =>
        [:examine_animal, Services::Commands::ExamineAnimalCommand, { animal_id: 'a1', veterinarian_id: 'v1' }],
      'addEnclosure(name: "丘", celsius: 28, capacity: 4)' =>
        [:add_enclosure, Services::Commands::AddEnclosureCommand,
         { name: '丘', celsius: 28, capacity: 4, climate_controlled: false }],
      'addEnclosure(name: "温室", celsius: 30, capacity: 2, climateControlled: true)' =>
        [:add_enclosure, Services::Commands::AddEnclosureCommand,
         { name: '温室', celsius: 30, capacity: 2, climate_controlled: true }],
      'cleanEnclosure(enclosureId: "e1", keeperId: "k1")' =>
        [:clean_enclosure, Services::Commands::CleanEnclosureCommand, { enclosure_id: 'e1', keeper_id: 'k1' }],
      'enrichEnclosure(enclosureId: "e1", keeperId: "k1")' =>
        [:enrich_enclosure, Services::Commands::EnrichEnclosureCommand, { enclosure_id: 'e1', keeper_id: 'k1' }],
      'assignKeeper(enclosureId: "e1", keeperId: "k1")' =>
        [:assign_keeper, Services::Commands::AssignKeeperCommand, { enclosure_id: 'e1', keeper_id: 'k1' }],
      'dischargeKeeper(enclosureId: "e1", keeperId: "k1")' =>
        [:discharge_keeper, Services::Commands::DischargeKeeperCommand, { enclosure_id: 'e1', keeper_id: 'k1' }],
      'hireKeeper(name: "田中", specialties: ["mammal", "bird"])' =>
        [:hire_keeper, Services::Commands::HireKeeperCommand, { name: '田中', specialties: %w[mammal bird] }],
      'hireVeterinarian(name: "山田")' =>
        [:hire_veterinarian, Services::Commands::HireVeterinarianCommand, { name: '山田' }],
      'makeRounds(keeperId: "k1")' =>
        [:make_rounds, Services::Commands::MakeRoundsCommand, { keeper_id: 'k1' }],
      'operateDay' =>
        [:operate_day, Services::Commands::OperateDayCommand, {}],
      'runDays(days: 7)' =>
        [:run_days, Services::Commands::RunDaysCommand, { days: 7 }],
      'setAdmissionFee(fee: 1800)' =>
        [:set_admission_fee, Services::Commands::SetAdmissionFeeCommand, { fee: 1800 }]
    }.each do |call, (use_case, command_class, attributes)|
      it "#{call} は Services::#{use_case.to_s.camelize} に #{attributes} を持つ #{command_class.name.split('::').last} を渡すこと" do
        service_class = stub_service(use_case, Services::Result.success(use_case, Object.new))

        execute("mutation { #{call} { __typename } }")

        expect(service_class).to have_received(:new)
          .with(command: an_instance_of(command_class).and(having_attributes(attributes)))
      end
    end
  end
end
