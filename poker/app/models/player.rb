class Player < ApplicationRecord
  belongs_to :game, dependent: :destroy
  belongs_to :user, dependent: :destroy
end
