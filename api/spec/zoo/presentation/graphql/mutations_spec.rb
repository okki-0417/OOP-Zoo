# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Presentation::Graphql::Mutations do
  commands = Zoo::Application::Commands
  result   = Zoo::Application::Result
  errors   = Zoo::Application::Errors
  catalog  = Zoo::Domain::SpeciesCatalog

  let(:container) { instance_double(Zoo::Composition::Container) }

  def execute(query)
    Zoo::Presentation::Graphql::Schema.execute(query, context: { container: }).to_h
  end

  describe 'BaseMutation の応答' do
    let(:lion) { build_adult(catalog.lion, name: 'レオ') }

    it 'サービスが success(value: レオ) を返すと、data.renameAnimal にその動物の name "レオ" が出ること' do
      allow(container).to receive(:rename_animal).and_return(result.success(:rename_animal, lion))

      response = execute('mutation { renameAnimal(animalId: "a1", newName: "レオ") { name } }')

      expect(response).to eq('data' => { 'renameAnimal' => { 'name' => 'レオ' } })
    end

    it "サービスが failure(AnimalNotFound '動物 a1 は存在しません') を返すと、data が null で errors[0] に message と extensions.code 'AnimalNotFound' が出ること" do
      error = errors::AnimalNotFound.new('動物 a1 は存在しません')
      allow(container).to receive(:rename_animal).and_return(result.failure(:rename_animal, error))

      response = execute('mutation { renameAnimal(animalId: "a1", newName: "レオ") { name } }')

      expect(response['data']).to be_nil
      expect(response['errors'].first).to include(
        'message' => '動物 a1 は存在しません', 'extensions' => { 'code' => 'AnimalNotFound' }
      )
    end

    it "サービスが failure(DomainError の CapacityExceeded) を返すと、extensions.code が 'CapacityExceeded' になること" do
      error = Zoo::Domain::Errors::CapacityExceeded.new('満員です')
      allow(container).to receive(:house_animal).and_return(result.failure(:house_animal, error))

      response = execute('mutation { houseAnimal(enclosureId: "e1", animalId: "a1") { name } }')

      expect(response['errors'].first['extensions']).to eq('code' => 'CapacityExceeded')
    end

    it "Command が ArgumentError を投げる runDays(days: 0) は、サービスを呼ばずに extensions.code 'InvalidArgument' になること" do
      allow(container).to receive(:run_days)

      response = execute('mutation { runDays(days: 0) { days } }')

      expect(container).not_to have_received(:run_days)
      expect(response['errors'].first).to include(
        'message' => 'days は1以上でなければなりません', 'extensions' => { 'code' => 'InvalidArgument' }
      )
    end
  end

  describe '引数からコマンドへの受け渡し' do
    {
      'acquireAnimal(speciesCode: "lion", name: "レオ", sex: MALE)' =>
        [:acquire_animal, commands::AcquireAnimalCommand, { species_code: 'lion', name: 'レオ', sex: :male }],
      'renameAnimal(animalId: "a1", newName: "シンバ")' =>
        [:rename_animal, commands::RenameAnimalCommand, { animal_id: 'a1', new_name: 'シンバ' }],
      'feedAnimal(animalId: "a1", keeperId: "k1", foodCode: "horse_meat")' =>
        [:feed_animal, commands::FeedAnimalCommand, { animal_id: 'a1', keeper_id: 'k1', food_code: 'horse_meat' }],
      'treatAnimal(animalId: "a1", veterinarianId: "v1")' =>
        [:treat_animal, commands::TreatAnimalCommand, { animal_id: 'a1', veterinarian_id: 'v1' }],
      'examineAnimal(animalId: "a1", veterinarianId: "v1")' =>
        [:examine_animal, commands::ExamineAnimalCommand, { animal_id: 'a1', veterinarian_id: 'v1' }],
      'transferAnimal(animalId: "a1", enclosureId: "e1")' =>
        [:transfer_animal, commands::TransferAnimalCommand, { animal_id: 'a1', enclosure_id: 'e1' }],
      'houseAnimal(enclosureId: "e1", animalId: "a1")' =>
        [:house_animal, commands::HouseAnimalCommand, { enclosure_id: 'e1', animal_id: 'a1' }],
      'releaseAnimal(animalId: "a1")' =>
        [:release_animal, commands::ReleaseAnimalCommand, { animal_id: 'a1' }],
      'addEnclosure(name: "丘", celsius: 28, capacity: 4)' =>
        [:add_enclosure, commands::AddEnclosureCommand,
         { name: '丘', celsius: 28, capacity: 4, climate_controlled: false }],
      'addEnclosure(name: "温室", celsius: 30, capacity: 2, climateControlled: true)' =>
        [:add_enclosure, commands::AddEnclosureCommand,
         { name: '温室', celsius: 30, capacity: 2, climate_controlled: true }],
      'cleanEnclosure(enclosureId: "e1", keeperId: "k1")' =>
        [:clean_enclosure, commands::CleanEnclosureCommand, { enclosure_id: 'e1', keeper_id: 'k1' }],
      'enrichEnclosure(enclosureId: "e1", keeperId: "k1")' =>
        [:enrich_enclosure, commands::EnrichEnclosureCommand, { enclosure_id: 'e1', keeper_id: 'k1' }],
      'assignKeeper(enclosureId: "e1", keeperId: "k1")' =>
        [:assign_keeper, commands::AssignKeeperCommand, { enclosure_id: 'e1', keeper_id: 'k1' }],
      'dischargeKeeper(enclosureId: "e1", keeperId: "k1")' =>
        [:discharge_keeper, commands::DischargeKeeperCommand, { enclosure_id: 'e1', keeper_id: 'k1' }],
      'hireKeeper(name: "田中", specialties: ["mammal", "bird"])' =>
        [:hire_keeper, commands::HireKeeperCommand, { name: '田中', specialties: %w[mammal bird] }],
      'hireVeterinarian(name: "山田")' =>
        [:hire_veterinarian, commands::HireVeterinarianCommand, { name: '山田' }],
      'makeRounds(keeperId: "k1")' =>
        [:make_rounds, commands::MakeRoundsCommand, { keeper_id: 'k1' }],
      'operateDay' =>
        [:operate_day, commands::OperateDayCommand, {}],
      'runDays(days: 7)' =>
        [:run_days, commands::RunDaysCommand, { days: 7 }],
      'setAdmissionFee(fee: 1800)' =>
        [:set_admission_fee, commands::SetAdmissionFeeCommand, { fee: 1800 }]
    }.each do |call, (use_case, command_class, attributes)|
      it "#{call} は Container##{use_case} に #{attributes} を持つ #{command_class.name.split('::').last} を渡すこと" do
        allow(container).to receive(use_case).and_return(result.success(use_case, Object.new))

        execute("mutation { #{call} { __typename } }")

        expect(container).to have_received(use_case).with(an_instance_of(command_class).and(having_attributes(attributes)))
      end
    end
  end
end
