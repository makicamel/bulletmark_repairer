# frozen_string_literal: true

class CreateAllTables < ActiveRecord::Migration[7.0]
  def self.up
    create_table 'plays' do |t|
      t.string :name
    end

    create_table 'companies' do |t|
      t.string :name
    end

    create_table 'actors' do |t|
      t.references :company
      t.string :name
    end

    create_table 'play_actors' do |t|
      t.references :play
      t.references :actor
    end

    create_table 'offices' do |t|
      t.references :company
      t.string :name
      t.string :address
    end
  end
end

CreateAllTables.up
