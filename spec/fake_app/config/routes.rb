# frozen_string_literal: true

BulletmarkRepairerTestApp::Application.routes.draw do
  resources :multiple_lines, only: [:index]
  resources :previous_lines, only: [:index]
end
