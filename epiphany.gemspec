$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "epiphany/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "epiphany"
  spec.version     = Epiphany::VERSION
  spec.authors     = ["Bunnarith Bao"]
  spec.email       = ["bunnarith.bao@gmail.com"]
  spec.homepage    = "http://www.geeklevel1000.com"
  spec.summary     = "Open Source Natural Language Processor and Machine Learning Library."
  spec.description = "Phrase tokenization for natural language processing. Custom entity tagging and intent detection data flow via machine learning perdective modeling and supervised learning."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.2.2"
  spec.add_dependency "redis"
  spec.add_dependency "redis-namespace"
  spec.add_dependency "nokogiri"
  spec.add_dependency "sqlite3"

  spec.add_development_dependency "pry"

  #spec.add_development_dependency "redis"
end
