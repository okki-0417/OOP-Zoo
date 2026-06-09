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

      attr_reader :id, :species, :name, :sex, :health, :hunger, :age_in_days, :cause_of_death, :parent_ids

      CRY_OUT_DAMAGE = 1
      # 1日あたりに増す空腹度。
      HUNGER_PER_DAY = 10
      # 飢餓状態で1日あたりに失う体力。
      STARVATION_DAMAGE_PER_DAY = 2

      def initialize(species:, name:, sex:, max_health:, voice: :default,
                     age_in_days: 0, sire: nil, dam: nil, id: Shared::Identifier.new)
        raise ArgumentError, '名前は一文字以上でなければなりません' if name.to_s.empty?
        raise ArgumentError, '日齢は0以上でなければなりません' if age_in_days.negative?

        @id = id
        @species = species
        @name = name
        @sex = sex
        @health = Shared::Health.full(max_health)
        @voice = voice == :default ? species.default_voice : voice
        @age_in_days = age_in_days
        @hunger = Shared::Hunger.satisfied
        @alive = true
        @illness = nil
        @parent_ids = [sire&.id, dam&.id].compact
      end

      attr_reader :illness

      # --- 鳴く ---

      def cry_out
        current_voice.tap { @health = @health.decreased_by(CRY_OUT_DAMAGE) if @alive }
      end

      def current_voice
        return '...' if incapacitated? || @voice.to_s.empty?

        @health.weak? ? "#{@voice}..." : @voice
      end

      def change_voice(new_voice)
        raise ArgumentError, '鳴き声はnilにできません' if new_voice.nil?

        @voice = new_voice
      end

      # --- 体力・体調 ---

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
        @alive
      end

      def dead?
        !@alive
      end

      # 体力が尽きているか衰弱で行動不能か。
      def incapacitated?
        dead? || @health.empty?
      end

      # 個体を死亡させる。理由(死因)は任意。
      def die(cause: :unknown)
        return self if dead?

        @alive = false
        @cause_of_death = cause
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

      # 発病・受傷する。
      def fall_ill(illness)
        raise Errors::DeadAnimal, "#{@name}は死亡しています" if dead?

        @illness = illness
        self
      end

      # 回復(治癒)する。
      def recover
        @illness = nil
        self
      end

      def sick?
        !@illness.nil?
      end

      # --- 加齢・空腹 ---

      # 指定日数ぶん歳をとる。空腹が進み、飢餓なら衰弱し、寿命を超えれば寿命死する。
      def grow_older(days = 1)
        raise ArgumentError, '日数は1以上でなければなりません' if days < 1
        return self if dead?

        @age_in_days += days
        get_hungrier(HUNGER_PER_DAY * days)
        @health = @health.decreased_by(STARVATION_DAMAGE_PER_DAY * days) if @hunger.starving?
        @health = @health.decreased_by(@illness.daily_damage * days) if sick?

        if past_lifespan?
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

      # --- ライフステージ・繁殖適性 ---

      def life_stage
        Shared::LifeStage.for(age_in_days: @age_in_days, species: @species)
      end

      def age_in_years
        @age_in_days / Shared::LifeStage::DAYS_PER_YEAR
      end

      # 性成熟しているか。
      def mature?
        life_stage.mature?
      end

      # 繁殖可能な状態か(生存・成熟・衰弱や病気がない)。
      def fertile?
        alive? && mature? && !@health.weak? && !sick?
      end

      # 異性・同種・双方繁殖可能なら交配できる。
      def can_breed_with?(other)
        other.is_a?(Animal) &&
          @species.same_species?(other.species) &&
          @sex.opposite?(other.sex) &&
          fertile? && other.fertile?
      end

      # --- 改名 ---

      def change_name(new_name)
        raise ArgumentError, '名前は一文字以上でなければなりません' if new_name.to_s.empty?

        @name = new_name
      end

      def to_s
        "#{@name}(#{@species.name_ja}/#{@sex.label}/#{life_stage.label})"
      end

      private

      def past_lifespan?
        @age_in_days > @species.lifespan_years * Shared::LifeStage::DAYS_PER_YEAR
      end
    end
  end
end
