# frozen_string_literal: true

class Company < ActiveRecord::Base
  has_many :actors
  has_many :offices
end
