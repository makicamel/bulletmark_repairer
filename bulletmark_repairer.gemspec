# frozen_string_literal: true

require_relative 'lib/bulletmark_repairer/version'

Gem::Specification.new do |spec|
  spec.name = 'bulletmark_repairer'
  spec.version = BulletmarkRepairer::VERSION
  spec.authors = ['makicamel']
  spec.email = ['unright@gmail.com']

  spec.summary = 'Auto corrector for N+1 queries detected at runtime with Bullet'
  spec.description = 'Auto corrector for N+1 queries detected at runtime with Bullet.'
  spec.homepage = 'https://github.com/makicamel/bulletmark_repairer'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0' # rubocop:disable Gemspec/RequiredRubyVersion

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/makicamel/bulletmark_repairer'
  spec.metadata['changelog_uri'] = 'https://github.com/makicamel/bulletmark_repairer/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'bullet'
  spec.add_dependency 'parser'
  spec.add_dependency 'rails'
end
