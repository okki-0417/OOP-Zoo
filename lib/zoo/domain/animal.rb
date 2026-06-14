# frozen_string_literal: true

module Zoo
  module Domain
    # 動物個体を表す集約ルート。
    #
    # 種(Species)を参照する固有の存在で、識別子で同一性が決まる。
    # 体力・空腹・加齢・生死といった内部状態を自身の不変条件のもとで管理し、
    # 外部からは振る舞い(鳴く・食べる・回復する・歳をとる)を通じてのみ変化する。
    class Animal
      include Events::Recorder
      include Shared::Entity

      CRY_OUT_DAMAGE = 1
      # 1日あたりに増す空腹度。
      HUNGER_PER_DAY = 10
      # 飢餓状態で1日あたりに失う体力。
      STARVATION_DAMAGE_PER_DAY = 2
      # 過度のストレス下で1日あたりに失う体力(免疫低下)。
      STRESS_DAMAGE_PER_DAY = 2

      attr_reader :id, :species, :name, :sex, :health, :hunger, :age_in_days, :death, :parent_ids, :illness, :stress

      def initialize(species:, name:, sex:, max_health:, voice: :default,
                     age_in_days: 0, sire: nil, dam: nil, id: Shared::Identifier.new)
        @id = id
        @species = species
        @name = Name.new(name)
        @sex = sex
        @health = Health.full(max_health)
        @voice = Voice.from(voice == :default ? species.default_voice : voice)
        @age_in_days = AgeInDays.new(age_in_days)
        @hunger = Hunger.satisfied
        @stress = Stress.calm
        @death = nil
        @illness = nil
        @immunities = []
        @parent_ids = [sire&.id, dam&.id].compact
      end

      # 保存済みの状態から復元する(永続化からの読み戻し用)。生成(new)の初期化規則を
      # 通さず、体力・空腹・加齢・病気・生死を保存値そのままに組み直す。voice は鳴き声の
      # 変更を保存しないため種の既定に戻す。
      def self.reconstitute(id:, species:, name:, sex:, health:, hunger:, age_in_days:, illness:, death:, parent_ids:,
                            stress: Stress.calm, immunities: [])
        allocate.tap do |animal|
          animal.instance_variable_set(:@id, id)
          animal.instance_variable_set(:@species, species)
          animal.instance_variable_set(:@name, name)
          animal.instance_variable_set(:@sex, sex)
          animal.instance_variable_set(:@health, health)
          animal.instance_variable_set(:@hunger, hunger)
          animal.instance_variable_set(:@stress, stress)
          animal.instance_variable_set(:@age_in_days, age_in_days)
          animal.instance_variable_set(:@voice, Voice.from(species.default_voice))
          animal.instance_variable_set(:@illness, illness)
          animal.instance_variable_set(:@immunities, immunities)
          animal.instance_variable_set(:@death, death)
          animal.instance_variable_set(:@parent_ids, parent_ids)
        end
      end

      def cry_out
        current_voice.tap { @health = @health.decreased_by(CRY_OUT_DAMAGE) if alive? }
      end

      def current_voice
        return '...' if incapacitated? || @voice.silent?

        @health.weak? ? "#{@voice}..." : @voice.to_s
      end

      def change_voice(new_voice)
        @voice = Voice.new(new_voice)
      end

      def heal(amount)
        raise ArgumentError, '回復量は0以上でなければなりません' if amount.negative?
        raise ArgumentError, '死んだ動物は回復できません' if dead?

        @health = @health.increased_by(amount)
        @health.current
      end

      # 後方互換のための現在体力(整数)。
      def current_health
        @health.current
      end

      def alive?
        @death.nil?
      end

      def dead?
        !alive?
      end

      # 体力が尽きているか衰弱で行動不能か。
      def incapacitated?
        dead? || @health.empty?
      end

      def die(cause: :unknown)
        return self if dead?

        @death = Death.new(cause: cause)
        record_event(Events::AnimalDied.new(animal: self, cause: cause))
        self
      end

      # この個体は other の親か。
      def parent_of?(other)
        other.is_a?(Animal) && other.parent_ids.include?(@id)
      end

      # 同じ親を持つ(全きょうだい/半きょうだい)か。
      def sibling_of?(other)
        other.is_a?(Animal) && !(@parent_ids & other.parent_ids).empty?
      end

      # 発病・受傷する。免疫を持つ病気にはかからない。
      def fall_ill(illness)
        raise Errors::DeadAnimal, "#{@name}は死亡しています" if dead?
        return self if immune_to?(illness)

        @illness = illness
        self
      end

      # 予防接種する。感染性の病気には、かかる前から免疫を獲得できる。
      # 感染性でない病気(骨折など)にはワクチンが無い。
      def vaccinate(illness)
        raise Errors::DeadAnimal, "#{@name}は死亡しています" if dead?
        raise Errors::VaccineUnavailable, "#{illness.name_ja}にはワクチンがありません" unless illness.contagious?

        @immunities << illness unless immune_to?(illness)
        self
      end

      # 回復(治癒)する。かかっていた病気には以後免疫を持つ。
      def recover
        @immunities << @illness if @illness && !immune_to?(@illness)
        @illness = nil
        self
      end

      def sick?
        !@illness.nil?
      end

      # この病気に免疫を持つ(かかって回復したことがある)か。
      def immune_to?(illness)
        @immunities.include?(illness)
      end

      def immunities
        @immunities.dup
      end

      # ストレスを与える(悪い飼育環境・社会的不適合などの結果)。
      def add_stress(amount)
        @stress = @stress.increased_by(amount)
        self
      end

      # ストレスを和らげる(良い飼育環境・社会的充足などの結果)。
      def relieve_stress(amount)
        @stress = @stress.decreased_by(amount)
        self
      end

      # ストレス状態か。
      def stressed?
        @stress.stressed?
      end

      # 指定日数ぶん歳をとる。空腹が進み、飢餓や過度のストレスなら衰弱し、
      # 寿命を超えれば寿命死する。
      def grow_older(days = 1)
        return self if dead?

        @age_in_days = @age_in_days.advanced_by(days)
        get_hungrier(HUNGER_PER_DAY * days)
        @health = @health.decreased_by(STARVATION_DAMAGE_PER_DAY * days) if @hunger.starving?
        @health = @health.decreased_by(@illness.daily_damage * days) if sick?
        @health = @health.decreased_by(STRESS_DAMAGE_PER_DAY * days) if @stress.severe?

        if @age_in_days.past_lifespan?(@species)
          die(cause: :old_age)
        elsif @health.empty?
          die(cause: sick? ? :illness : :starvation)
        end
        self
      end

      def get_hungrier(amount)
        @hunger = @hunger.increased_by(amount)
        self
      end

      # 空腹度を満たす(給餌の効果)。
      def satisfy_hunger(amount)
        @hunger = @hunger.decreased_by(amount)
        self
      end

      # 餌を食べる。食性に合わない餌は受け付けず、死んだ個体は食べられない。
      def eat(food)
        raise Errors::DeadAnimal, "#{@name}は死亡しているため給餌できません" if dead?

        unless @species.diet_type.accepts?(food.category)
          raise Errors::IncompatibleFood,
                "#{@species.name_ja}(#{@species.diet_type.label})に#{food.name_ja}は与えられません"
        end

        satisfy_hunger(food.satiety)
        self
      end

      def hungry?
        @hunger.hungry?
      end

      def starving?
        @hunger.starving?
      end

      def life_stage
        @age_in_days.life_stage(@species)
      end

      def age_in_years
        @age_in_days.years
      end

      # 性成熟しているか。
      def mature?
        @age_in_days.mature?(@species)
      end

      # 離乳して親に依存しなくなったか。
      def weaned?
        @age_in_days.weaned?(@species)
      end

      # 繁殖可能な状態か(生存・成熟・高齢前で、衰弱や病気がなく、ストレス過多でもない)。
      def fertile?
        alive? && mature? && !@age_in_days.past_breeding_age?(@species) &&
          !@health.weak? && !sick? && !stressed?
      end

      # 異性・同種・双方繁殖可能なら交配できる。
      def can_breed_with?(other)
        other.is_a?(Animal) &&
          @species.same_species?(other.species) &&
          @sex.opposite?(other.sex) &&
          fertile? && other.fertile?
      end

      def change_name(new_name)
        old_name = @name.to_s
        @name = Name.new(new_name)
        record_event(Events::AnimalRenamed.new(animal: self, old_name: old_name, new_name: @name.to_s))
        self
      end

      def to_s
        "#{@name}(#{@species.name_ja}/#{@sex.label}/#{life_stage.label})"
      end
    end
  end
end
