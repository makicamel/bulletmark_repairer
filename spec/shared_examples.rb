# frozen_string_literal: true

RSpec.shared_examples 'correctly patched' do
  let(:filename) { "spec/fake_app/app/controllers/#{described_class.to_s.underscore}.rb" }

  it do
    File.open(filename) do |f|
      src = f.read
      expect(src.include?(original_src)).to eq true
      expect(src.include?(patched_src)).to eq false
    end

    subject
    expect(response).to have_http_status 200

    File.open(filename) do |f|
      src = f.read
      expect(src.include?(original_src)).to eq false
      expect(src.include?(patched_src)).to eq true
    end

    system("git checkout #{filename}")
  end
end

RSpec.shared_examples 'not patched' do
  let(:filename) { "spec/fake_app/app/controllers/#{described_class.to_s.underscore}.rb" }

  it do
    File.open(filename) do |f|
      src = f.read
      expect(src.include?(src)).to eq true
    end

    subject
    expect(response).to have_http_status 200

    File.open(filename) do |f|
      src = f.read
      expect(src.include?(src)).to eq true
    end
  end
end
