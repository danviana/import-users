# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  email      :string           not null
#  gender     :integer
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    gender { rand(2) }

    trait :with_picture do
      after(:build) do |user|
        user.picture.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'image.jpg')), filename: 'image')
      end
    end
  end
end
