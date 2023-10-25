# frozen_string_literal: true

class Office < ActiveRecord::Base
  belongs_to :company
end
