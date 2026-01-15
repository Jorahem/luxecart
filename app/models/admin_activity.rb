class AdminActivity < ApplicationRecord
  belongs_to :admin
  belongs_to :trackable, polymorphic: true, optional: true

  # metadata field can store JSON about the action (old/new values etc)
  serialize :metadata, JSON
end