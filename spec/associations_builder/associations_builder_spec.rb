# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BulletmarkRepairer::Associations do
  describe '#build_associations!' do
    let(:associations) { described_class.new(parent_marker, application_associations) }
    let(:application_associations) { BulletmarkRepairer::ApplicationAssociations.new }
    let(:parent_marker) { double(:marker, base_class: parent_attributes.keys.first, associations: parent_attributes.values.first) }
    let(:child_marker) { double(:marker, base_class: child_attributes.keys.first, associations: child_attributes.values.first) }

    subject { associations.__send__(:build_associations!, marker: child_marker, associations: parent_marker.associations, parent_keys: parent_keys) }

    context 'simple pattern' do
      let(:parent_keys) { [:base] }
      let(:parent_attributes) { { 'Play' => [:actor] } }
      let(:child_attributes) { { 'Actor' => [:company] } }

      it do
        expect { subject }.to change { associations.instance_variable_get(:@associations) }
          .from({ base: [:actor] })
          .to({ base: [{ actor: [:company] }] })
      end
    end

    context 'when parent association is pluralized' do
      let(:parent_keys) { [:base] }
      let(:parent_attributes) { { 'Play' => [:actors] } }
      let(:child_attributes) { { 'Actor' => [:company] } }

      it do
        expect { subject }.to change { associations.instance_variable_get(:@associations) }
          .from({ base: [:actors] })
          .to({ base: [{ actors: [:company] }] })
      end
    end

    context 'when parent association has nested associations and value is an array' do
      let(:parent_keys) { [:base] }
      let(:parent_attributes) { { 'Play' => { actors: [:company] } } }
      let(:child_attributes) { { 'Actor' => [:works] } }

      it do
        expect { subject }.to change { associations.instance_variable_get(:@associations) }
          .from({ base: { actors: [:company] } })
          .to({ base: { actors: %i[company works] } })
      end
    end

    context 'when parent association has nested associations and value is not an array' do
      let(:parent_keys) { [:base] }
      let(:parent_attributes) { { 'Play' => { actors: :company } } }
      let(:child_attributes) { { 'Actor' => [:works] } }

      it do
        expect { subject }.to change { associations.instance_variable_get(:@associations) }
          .from({ base: { actors: :company } })
          .to({ base: { actors: %i[company works] } })
      end
    end

    context 'when parent association has multiple associations' do
      let(:parent_keys) { [:base] }
      let(:parent_attributes) { { 'Play' => %i[actors staffs] } }
      let(:child_attributes) { { 'Actor' => [:company] } }

      it do
        expect { subject }.to change { associations.instance_variable_get(:@associations) }
          .from({ base: %i[actors staffs] })
          .to({ base: [:staffs, { actors: [:company] }] })
      end
    end

    context 'when parent association has nested associations and multiple associations' do
      let(:parent_keys) { [:base] }
      let(:parent_attributes) { { 'Play' => [{ actors: :company }, :staffs] } }
      let(:child_attributes) { { 'Actor' => [:works] } }

      it do
        expect { subject }.to change { associations.instance_variable_get(:@associations) }
          .from({ base: [{ actors: :company }, :staffs] })
          .to({ base: [{ actors: %i[company works] }, :staffs] })
      end
    end

    context 'when parent association has multiple nested associations and value is not an array' do
      let(:parent_keys) { [:base] }
      let(:parent_attributes) { { 'Play' => [{ actors: :works }] } }
      let(:child_attributes) { { 'Work' => [:staffs] } }

      it do
        expect { subject }.to change { associations.instance_variable_get(:@associations) }
          .from({ base: [{ actors: :works }] })
          .to({ base: [{ actors: { works: [:staffs] } }] })
      end
    end

    context 'when parent association has multiple nested associations and value is an array' do
      let(:parent_keys) { [:base] }
      let(:parent_attributes) { { 'Play' => [{ actors: %i[works snses] }] } }
      let(:child_attributes) { { 'Work' => [:staffs] } }

      it do
        expect { subject }.to change { associations.instance_variable_get(:@associations) }
          .from({ base: [{ actors: %i[works snses] }] })
          .to({ base: [{ actors: [:snses, { works: [:staffs] }] }] })
      end
    end
  end
end
