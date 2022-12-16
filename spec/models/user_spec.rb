require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to define_enum_for(:gender).with_values(%i[male female]) }
    it { is_expected.to be_valid }
  end

  describe '#picture' do
    subject { create(:user, :with_picture).picture }

    it { is_expected.to be_an_instance_of(ActiveStorage::Attached::One) }
    it { expect(subject).to be_attached }
  end
end
