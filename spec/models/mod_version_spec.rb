require 'rails_helper'

RSpec.describe ModVersion, :type => :model do
  subject(:version) { build :mod_version }

  describe '#number' do
    it { expect(version).to respond_to :number }
    it { expect(version.number).to be_kind_of String }
  end

  describe '#released_at' do
    it { expect(version).to respond_to :released_at }
    it { expect(version.released_at).to be_kind_of Time }
  end

  describe '#mod' do
    it { expect(version).to respond_to :mod }
  end

  describe '#precise_game_versions_string' do
    it { expect(version).to respond_to :precise_game_versions_string }
    it { expect(version.precise_game_versions_string).to be_kind_of String }
  end

  describe '#game_versions' do
    it { expect(version).to respond_to :game_versions }
    it { expect(version.game_versions.build).to be_kind_of GameVersion }

    it 'should generate #mod_game_versions when assigning #game_versions' do
      game_versions  = create_list :game_version, 3
      mod = create :mod
      mod_version = build :mod_version, mod: mod
      mod_version.game_versions = game_versions
      mod_version.save!
      mod_version.mod_game_versions.size.should eq 3
    end

    it 'should add #mod_id to all th #mod_game_versions generated by #game_versions' do
      game_versions  = create_list :game_version, 3
      mod = create :mod
      mod_version = build :mod_version, mod: mod
      mod_version.game_versions = game_versions
      mod_version.save!
      mod_game_versions = ModGameVersion.all
      mod_game_versions.map(&:mod_id).should eq [mod.id, mod.id, mod.id]
    end
  end

  describe '#mod_game_versions' do
    it { expect(version).to respond_to :mod_game_versions }
    it { expect(version.mod_game_versions.build).to be_kind_of ModGameVersion }

    it 'should add the #mod_id to the #mod_game_versions before saving' do
      mod = create :mod
      mod_version = build :mod_version, mod: mod
      mod_game_versions = []
      mod_game_versions << create(:mod_game_version)
      mod_game_versions << create(:mod_game_version)
      mod_game_versions << create(:mod_game_version)

      mod_version.mod_game_versions = mod_game_versions
      mod_version.save!
      mod_game_versions = ModGameVersion.all

      mod_game_versions.map(&:mod_id).should eq [mod.id, mod.id, mod.id]
    end
  end

  describe 'validations' do
    it 'should be invalid without a mod' do
      expect(build(:mod_version, mod_id: nil)).to be_invalid
    end

    it 'should be invalid with empty number' do
      expect(build(:mod_version, number: nil)).to be_invalid
    end

    # context 'no game versions were selected' do
    #    it { expect(build(:mod_version, game_versions: [])).to be_invalid }
    # end

    it 'should be invalid with an invalid file' do
      invalid_file = build(:mod_file, attachment: File.new(Rails.root.join('spec', 'fixtures', 'test.jpg')))

      expect(build(:mod_version, files: [invalid_file])).to be_invalid
    end

    it 'should be invalid when selecting 2 non consecutive game versions' do
      gv1 = create :game_version
      gv2 = create :game_version
      gv3 = create :game_version

      mod_version = build :mod_version, game_versions: [gv1, gv3]

      expect(mod_version).to be_invalid
    end

    it 'should be valid when selecting consecutive game versions' do
      gv1 = create :game_version
      gv2 = create :game_version
      gv3 = create :game_version

      mod_version = build :mod_version, game_versions: [gv2, gv3]

      expect(mod_version).to be_valid
    end

    it 'should be invalid without a release date' do
      expect(build(:mod_version, released_at: nil)).to be_invalid
    end
  end

  # describe '#game_versions_string' do
  #   it { expect(version).to respond_to :game_versions_string }

  #   describe 'validations' do
  #     before :each do
  #       g0 = create :game_version_group, number: '0.0.x'
  #       g1 = create :game_version_group, number: '0.1.x'
  #       g2 = create :game_version_group, number: '0.2.x'
  #       create :game_version, number: '0.0.1', group: g0
  #       create :game_version, number: '0.0.2', group: g0
  #       create :game_version, number: '0.0.3', group: g0
  #       create :game_version, number: '0.1.0', group: g1
  #       create :game_version, number: '0.1.1', group: g1
  #       create :game_version, number: '0.1.2', group: g1
  #       create :game_version, number: '0.2.0', group: g2
  #       create :game_version, number: '0.2.1', group: g2
  #     end

  #     valid = ['0.0.1', '0.0.1-0.0.2', '0.0.x', '0.0.x-0.1.x', '0.0.3-0.0.x', '0.1.0-0.2.0']
  #     invalid = ['0.0.0', '0.0.2-0.0.1', 'potato', '0.0.1-banana', '0.0.1-0.0.4', '0.0.1-0.2.z', '0.0.1, 0.0.2, 0.0.3']

  #     it { expect(build :mod_version, game_versions_string: 'rsa').to be_invalid }
  #     it { expect(build :mod_version, game_versions_string: '1.1.0.1').to be_invalid }
  #     it { expect(build :mod_version, game_versions_string: '1.1').to be_invalid }
  #     it { expect(build :mod_version, game_versions_string: '0.1.x').to be_valid }
  #     it { expect(build :mod_version, game_versions_string: '0.1.x-0.1.1').to be_invalid }
  #     it { expect(build :mod_version, game_versions_string: '0.0.1-0.0.3').to be_valid }
  #     it { expect(build :mod_version, game_versions_string: '0.0.1, 0.0.2').to be_valid }
  #   end
  # end

  # describe '#game_version_start' do
  #   it { expect(version).to respond_to :game_version_start }
  #   it 'should be a GameVersion' do
  #     version.build_game_version_start
  #     expect(version.game_version_start).to be_kind_of GameVersion
  #   end
  # end

  # describe '#game_version_end' do
  #   it { expect(version).to respond_to :game_version_end }
  #   it 'should be a GameVersion' do
  #     version.build_game_version_end
  #     expect(version.game_version_end).to be_kind_of GameVersion
  #   end

  #   context 'validating' do
  #     it 'should be invalid if both #game_version_start and #game_version_end are null' do
  #       version = build :mod_version, game_version_start: nil, game_version_end_id: 12389732894213
  #       expect(version).to be_invalid
  #     end
  #   end

  #   context 'saving' do
  #     it 'should nullify it if belongs to #game_version_start group' do
  #       gversion1 = create :game_version, is_group: true
  #       gversion2 = create :game_version, group: gversion1
  #       version.game_version_start = gversion1
  #       version.game_version_end = gversion2
  #       version.save!
  #       version.reload
  #       version.game_version_start.should eq gversion1
  #       version.game_version_end.should eq nil
  #     end

  #     it 'should nullify it if its the same as #game_version_start' do
  #       gversion1 = create :game_version
  #       version.game_version_start = gversion1
  #       version.game_version_end = gversion1
  #       version.save!
  #       version.reload
  #       version.game_version_end.should eq nil
  #     end

  #     it 'should switch versions if the end version is older than the start version' do
  #       gversion1 = create :game_version, sort_order: 1
  #       gversion2 = create :game_version, sort_order: 2
  #       version.game_version_start = gversion2
  #       version.game_version_end = gversion1
  #       version.save!
  #       version.reload
  #       version.game_version_start.should eq gversion1
  #       version.game_version_end.should eq gversion2
  #     end

  #     it 'should allow #game_version_end to be null' do
  #       version = create :mod_version, game_version_end: nil
  #     end

  #     it 'should switch #game_version_end with #game_version_start if #game_version_start is null' do
  #       gversion = create :game_version
  #       version = build :mod_version, game_version_start: nil, game_version_end: gversion
  #       version.save!
  #       expect(version.game_version_end).to eq nil
  #       expect(version.game_version_start).to eq gversion
  #     end
  #   end
  # end

  describe '#sort_order' do
    it { expect(version).to respond_to :sort_order}
    it { expect(version.sort_order).to be_kind_of Integer }
  end

  # describe 'scopes' do
  #   describe '.sort_by_game_version_start' do
  #     it 'should return th mods versions by the #sort_order of the respective #game_version_start' do
  #       gv1 = create :game_version, sort_order: 1
  #       gv2 = create :game_version, sort_order: 2
  #       mod1 = create :mod_version, game_version_start: gv2
  #       mod2 = create :mod_version, game_version_start: gv1

  #       expect(ModVersion.get_by_game_version_start).to eq [mod2, mod1]
  #     end
  #   end

  #   describe '.sort_by_game_version_end' do
  #     it 'should return th mods versions by the #sort_order of the respective #game_version_end' do
  #       gv1 = create :game_version, sort_order: 1
  #       gv2 = create :game_version, sort_order: 2
  #       gv_1 = create :game_version, sort_order: 0
  #       gv_2 = create :game_version, sort_order: 0
  #       mod1 = create :mod_version, game_version_end: gv2, game_version_start: gv_2
  #       mod2 = create :mod_version, game_version_end: gv1, game_version_start: gv_1

  #       # puts ModVersion.get_by_game_version_end.to_sql

  #       expect(ModVersion.get_by_game_version_end).to eq [mod2, mod1]
  #     end
  #   end
  # end

end
