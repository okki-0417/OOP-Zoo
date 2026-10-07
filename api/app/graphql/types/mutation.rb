# frozen_string_literal: true

module Types
  class Mutation < BaseObject
    field :acquire_animal, mutation: Mutations::AcquireAnimal
    field :add_enclosure, mutation: Mutations::AddEnclosure
    field :assign_keeper, mutation: Mutations::AssignKeeper
    field :clean_enclosure, mutation: Mutations::CleanEnclosure
    field :discharge_keeper, mutation: Mutations::DischargeKeeper
    field :enrich_enclosure, mutation: Mutations::EnrichEnclosure
    field :examine_animal, mutation: Mutations::ExamineAnimal
    field :feed_animal, mutation: Mutations::FeedAnimal
    field :hire_keeper, mutation: Mutations::HireKeeper
    field :hire_veterinarian, mutation: Mutations::HireVeterinarian
    field :house_animal, mutation: Mutations::HouseAnimal
    field :make_rounds, mutation: Mutations::MakeRounds
    field :operate_day, mutation: Mutations::OperateDay
    field :release_animal, mutation: Mutations::ReleaseAnimal
    field :rename_animal, mutation: Mutations::RenameAnimal
    field :run_days, mutation: Mutations::RunDays
    field :set_admission_fee, mutation: Mutations::SetAdmissionFee
    field :transfer_animal, mutation: Mutations::TransferAnimal
    field :treat_animal, mutation: Mutations::TreatAnimal
  end
end
