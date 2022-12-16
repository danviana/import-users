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
class User < ApplicationRecord
  validates :name, :email, presence: true, allow_blank: false

  has_one_attached :picture

  enum gender: {
    male: 0,
    female: 1
  }
end
