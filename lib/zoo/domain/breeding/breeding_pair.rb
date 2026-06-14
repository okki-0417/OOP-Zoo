# frozen_string_literal: true

module Zoo
  module Domain
    module Breeding
      # 繁殖ペアを表す集約。一組の雌雄を結びつけ、交尾→妊娠/抱卵→出産/孵化の
      # ライフサイクルを管理し、誕生(AnimalBorn)イベントを記録する。
      class BreedingPair
        include Events::Recorder

        # 新生個体の初期最大体力(指定がなければこの値)。
        NEWBORN_HEALTH = 50

        attr_reader :sire, :dam

        def initialize(sire:, dam:)
          raise Errors::BreedingNotAllowed, 'sireはオスでなければなりません' unless sire.sex.male?
          raise Errors::BreedingNotAllowed, 'damはメスでなければなりません' unless dam.sex.female?

          reason = BreedingPolicy.rejection_reason(sire, dam)
          raise Errors::BreedingNotAllowed, reason if reason

          @sire = sire
          @dam = dam
          @gestation_days = nil
        end

        def species
          @dam.species
        end

        # 交尾する。妊娠/抱卵を開始する。繁殖期(春)でなければ成立しない。
        def mate(season: Operations::Season.spring)
          raise Errors::BreedingNotAllowed, '既に妊娠/抱卵中です' if expecting?
          raise Errors::BreedingNotAllowed, "#{season.label}は繁殖期ではありません" unless season.breeding_season?

          @gestation_days = 0
          self
        end

        def expecting?
          !@gestation_days.nil?
        end

        # 妊娠/抱卵を日数ぶん進める。
        def advance(days = 1)
          return self unless expecting?

          @gestation_days += days
          self
        end

        # 出産/孵化できる状態か(妊娠/抱卵期間に達したか)。
        def ready_to_deliver?
          expecting? && @gestation_days >= species.gestation_period_days
        end

        # 出産/孵化する。新生個体を生成して返し、AnimalBornを記録する。
        # inbreeding(近交係数 0〜1)が高いほど近交弱勢で最大体力が下がる。
        def deliver(name:, sex:, max_health: NEWBORN_HEALTH, inbreeding: 0.0)
          raise Errors::BreedingNotAllowed, 'まだ出産/孵化の時期ではありません' unless ready_to_deliver?

          offspring = Animal.new(
            species: species, name: name, sex: sex, max_health: newborn_vitality(max_health, inbreeding),
            age_in_days: 0, sire: @sire, dam: @dam
          )
          @gestation_days = nil

          record_event(Events::AnimalBorn.new(animal: offspring, sire_id: @sire.id, dam_id: @dam.id))
          offspring
        end

        def to_s
          "#{species.name_ja}の繁殖ペア(#{@sire.name}×#{@dam.name})"
        end

        private

        # 近交弱勢: 近交係数に比例して最大体力を下げる。最低1は保証する。
        def newborn_vitality(base, inbreeding)
          (base * (1.0 - inbreeding)).round.clamp(1, base)
        end
      end
    end
  end
end
