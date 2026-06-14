# frozen_string_literal: true

module Zoo
  module Domain
    module Husbandry
      # 飼育エリアを表す集約。動物個体を収容し、その収容に関する不変条件を守る。
      #
      # 不変条件:
      #   - 収容数は定員を超えない
      #   - 収容する個体の種は、このエリアの気候(気温)に適応できる
      #   - 既存の同居個体と相性が両立する(CohabitationPolicy)
      #   - 死亡個体は収容しない
      #
      # エリアは動物が暮らすほど汚れ、清掃で清潔さを取り戻す。
      class Enclosure
        include Shared::Entity
        attr_reader :id, :name, :temperature, :capacity, :cleanliness, :enrichment

        # 定員1枠あたりの標準面積(m²)。area_sqm 未指定のエリアの広さの算出に使う。
        AREA_PER_SLOT_SQM = 100

        # 1日経過で薄れる刺激の量。
        ENRICHMENT_DECAY_PER_DAY = 2

        def initialize(name:, temperature:, capacity:, area_sqm: nil, id: Shared::Identifier.new)
          raise ArgumentError, 'エリア名は必須です' if name.to_s.empty?
          raise ArgumentError, '定員は1以上でなければなりません' unless capacity.is_a?(Integer) && capacity.positive?

          @id = id
          @name = name
          @temperature = temperature
          @capacity = capacity
          @area_sqm = area_sqm
          @cleanliness = Cleanliness.spotless
          @enrichment = Enrichment.stimulating
          @occupants = []
        end

        # 保存済みの状態から復元する(永続化からの読み戻し用)。清潔度・収容個体を
        # 保存値そのままに組み直す。
        def self.reconstitute(id:, name:, temperature:, capacity:, cleanliness:, occupants:)
          allocate.tap do |enclosure|
            enclosure.instance_variable_set(:@id, id)
            enclosure.instance_variable_set(:@name, name)
            enclosure.instance_variable_set(:@temperature, temperature)
            enclosure.instance_variable_set(:@capacity, capacity)
            enclosure.instance_variable_set(:@area_sqm, nil)
            enclosure.instance_variable_set(:@cleanliness, cleanliness)
            enclosure.instance_variable_set(:@enrichment, Enrichment.stimulating)
            enclosure.instance_variable_set(:@occupants, occupants)
          end
        end

        # 個体を収容する。不変条件に反する場合はドメイン例外を送出する。
        def admit(animal)
          violation = violation_for(animal)
          raise violation if violation

          @occupants << animal
          self
        end

        # 収容可能か(例外を投げずに判定)。
        def can_admit?(animal)
          violation_for(animal).nil?
        end

        # 収容できない理由(可能ならnil)。
        def rejection_reason(animal)
          violation_for(animal)&.message
        end

        # 個体を退去させる。
        def release(animal)
          @occupants.delete(animal)
          self
        end

        def occupants
          @occupants.dup
        end

        def population
          @occupants.size
        end

        # 区画の広さ(m²)。明示が無ければ定員から標準面積を算出する。
        def area_sqm
          @area_sqm || capacity * AREA_PER_SLOT_SQM
        end

        def vacancies
          @capacity - population
        end

        def full?
          vacancies <= 0
        end

        def empty?
          @occupants.empty?
        end

        def houses?(animal)
          @occupants.include?(animal)
        end

        # 収容中の種(重複なし)。
        def species_present
          @occupants.map(&:species).uniq
        end

        # --- 清掃 ---

        def clean(amount = 100)
          @cleanliness = @cleanliness.cleaned_by(amount)
          self
        end

        def soil(amount)
          @cleanliness = @cleanliness.soiled_by(amount)
          self
        end

        def filthy?
          @cleanliness.filthy?
        end

        # --- 環境エンリッチメント(刺激) ---

        # 刺激を補充する(採食装置・遊具・隠れ場所などの導入)。
        def enrich(amount = 100)
          @enrichment = @enrichment.enriched_by(amount)
          self
        end

        # 刺激を薄れさせる。
        def deplete_enrichment(amount)
          @enrichment = @enrichment.depleted_by(amount)
          self
        end

        # 殺風景か(刺激が枯れているか)。
        def barren?
          @enrichment.barren?
        end

        # --- 時間経過 ---

        # 1日経過させる。不衛生なエリアでは健康な個体が発病し、各個体は飼育環境・社会的
        # 状況に応じてストレスが増減し、収容個体が歳をとり、エリアは頭数ぶん汚れる。
        # 死亡した個体はエリアから取り除き、その一覧を返す。
        def pass_day(season: Operations::Season.spring)
          spread_disease_if_filthy
          Medical::Contagion.spread(self)
          @occupants.each do |animal|
            next if animal.dead?

            apply_welfare(animal, season)
            animal.grow_older(1)
          end
          soil(@occupants.size)
          deplete_enrichment(ENRICHMENT_DECAY_PER_DAY)
          dead = @occupants.select(&:dead?)
          dead.each { |a| @occupants.delete(a) }
          dead
        end

        private

        # その日の飼育環境・社会的状況からストレスを増減させる。
        def apply_welfare(animal, season)
          delta = Welfare.daily_stress(animal, self, season: season)
          delta.negative? ? animal.relieve_stress(-delta) : animal.add_stress(delta)
        end

        # 不衛生(filthy)なエリアでは、健康な個体が寄生虫感染を起こす。清掃を怠ると
        # 病気→衰弱死につながる、という連鎖を生む。
        def spread_disease_if_filthy
          return unless filthy?

          @occupants.each do |animal|
            animal.fall_ill(Medical::IllnessCatalog.parasite) if animal.alive? && !animal.sick?
          end
        end

        # 収容を妨げる違反を表す例外インスタンスを返す(無ければnil)。送出はしない。
        def violation_for(animal)
          if animal.dead?
            return Errors::DeadAnimal.new("#{animal.name}は死亡しているため収容できません")
          end

          if full?
            return Errors::CapacityExceeded.new("#{@name}は定員#{@capacity}に達しています")
          end

          unless animal.species.habitable?(@temperature)
            return Errors::ClimateMismatch.new(
              "#{animal.species.name_ja}は#{@temperature}の#{@name}に適応できません"
            )
          end

          species_present.each do |resident|
            reason = CohabitationPolicy.incompatibility_reason(resident, animal.species)
            return Errors::IncompatibleCohabitation.new(reason) if reason
          end

          nil
        end
      end
    end
  end
end
