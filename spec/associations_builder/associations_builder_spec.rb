# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BulletmarkRepairer::Associations do
  describe '#build_associations!' do
    let(:associations) { described_class.new(parent_marker) }
    let(:parent_marker) { double(:marker, base_class: parent_attributes.keys.first, associations: parent_attributes.values.first, direct_associations: parent_attributes.values.first) }
    let(:child_marker) { double(:marker, base_class: child_attributes.keys.first, associations: child_attributes.values.first) }

    subject { associations.__send__(:build_associations!, marker: child_marker, associations: parent_marker.associations, parent_key:) }

    context 'simple pattern' do
      let(:parent_key) { :base }
      let(:parent_attributes) { { 'Play' => [:actor] } }
      let(:child_attributes) { { 'Actor' => [:company] } }

      it do
        expect { subject }.to change { associations.instance_variable_get(:@associations) }
          .from({ base: [:actor] })
          .to({ base: { actor: [:company] } })
      end
    end

    context 'when parent association is pluralized' do
      let(:parent_key) { :base }
      let(:parent_attributes) { { 'Play' => [:actors] } }
      let(:child_attributes) { { 'Actor' => [:company] } }

      it do
        expect { subject }.to change { associations.instance_variable_get(:@associations) }
          .from({ base: [:actors] })
          .to({ base: { actors: [:company] } })
      end
    end

    context 'when parent association is nested and value is an array' do
      let(:parent_key) { :base }
      let(:parent_attributes) { { 'Play' => { actors: [:company] } } }
      let(:child_attributes) { { 'Actor' => [:works] } }

      it do
        expect { subject }.to change { associations.instance_variable_get(:@associations) }
          .from({ base: { actors: [:company] } })
          .to({ base: { actors: %i[company works] } })
      end
    end

    context 'when parent association is nested and value is not an array' do
      let(:parent_key) { :base }
      let(:parent_attributes) { { 'Play' => { actors: :company } } }
      let(:child_attributes) { { 'Actor' => [:works] } }

      it do
        expect { subject }.to change { associations.instance_variable_get(:@associations) }
          .from({ base: { actors: :company } })
          .to({ base: { actors: %i[company works] } })
      end
    end
  end
end
