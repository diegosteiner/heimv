# frozen_string_literal: true

# == Schema Information
#
# Table name: home_operators
#
#  id             :bigint           not null, primary key
#  index          :integer
#  remarks        :text
#  responsibility :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  home_id        :bigint           not null
#  operator_id    :bigint           not null
#
# Indexes
#
#  index_home_operators_on_home_id         (home_id)
#  index_home_operators_on_index           (index)
#  index_home_operators_on_operator_id     (operator_id)
#  index_home_operators_on_responsibility  (responsibility)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (operator_id => operators.id)
#
class HomeOperator < ApplicationRecord
  include RankedModel

  belongs_to :home, inverse_of: :home_operators
  belongs_to :operator, inverse_of: :home_operators

  enum responsibility: Operator::RESPONSIBILITIES, _suffix: true

  validates :responsibility, presence: true
  ranks :index, with_same: :home_id
end
