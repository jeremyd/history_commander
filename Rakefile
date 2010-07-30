require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "history_commander"
    gem.summary = %Q{Take command of your shell history!}
    gem.description = %Q{History Commander is a program designed to keep your shell history in sync across all installations. }
    gem.email = "jeremy@rubyonlinux.org"
    gem.homepage = "http://github.com/jeremyd/history_commander"
    gem.authors = ["Jeremy Deininger"]
    gem.add_dependency "eventmachine"
    gem.add_dependency "eventmachine-tail"
    gem.add_dependency "amqp"
    gem.add_dependency "json"
    gem.add_dependency "simple-daemon"
    gem.add_dependency "trollop"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "history_commander #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
