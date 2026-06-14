# frozen_string_literal: true

require 'spec_helper'

# SocialStructure の判定上の保証。序列の意味は spec/knowledge/「群れと社会構造」を参照。
RSpec.describe Zoo::Domain::Husbandry::SocialStructure do
  catalog = Zoo::Domain::Taxonomy::SpeciesCatalog
  sex = Zoo::Domain::Animal::Sex

  def savanna
    Zoo::Domain::Husbandry::Enclosure.new(
      name: '丘', temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 6
    )
  end

  describe '.subordinate_male?' do
    it '成熟オスが複数いると、年長でない方が序列下位であること' do
      enclosure = savanna
      senior = build_animal(catalog.lion, name: '長老', sex: sex.male, age_in_days: 4000)
      junior = build_adult(catalog.lion, name: '若', sex: sex.male)
      enclosure.admit(senior)
      enclosure.admit(junior)

      expect(described_class.subordinate_male?(junior, enclosure)).to be(true)
      expect(described_class.subordinate_male?(senior, enclosure)).to be(false)
    end

    it 'オスが1頭だけなら序列下位でないこと' do
      enclosure = savanna
      male = build_adult(catalog.lion, sex: sex.male)
      enclosure.admit(male)
      enclosure.admit(build_adult(catalog.lion, sex: sex.female))

      expect(described_class.subordinate_male?(male, enclosure)).to be(false)
    end

    it 'メスは序列闘争の対象でないこと' do
      enclosure = savanna
      enclosure.admit(build_adult(catalog.lion, name: 'オス1', sex: sex.male))
      enclosure.admit(build_adult(catalog.lion, name: 'オス2', sex: sex.male))
      female = build_adult(catalog.lion, name: 'メス', sex: sex.female)
      enclosure.admit(female)

      expect(described_class.subordinate_male?(female, enclosure)).to be(false)
    end

    it '未成熟のオスは序列を争わないこと' do
      enclosure = savanna
      enclosure.admit(build_adult(catalog.lion, name: '成獣', sex: sex.male))
      cub = build_animal(catalog.lion, name: '仔', sex: sex.male, age_in_days: 0)
      enclosure.admit(cub)

      expect(described_class.subordinate_male?(cub, enclosure)).to be(false)
    end
  end
end
