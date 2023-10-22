# frozen_string_literal: true

class Company < ActiveRecord::Base
  has_many :actors
end
