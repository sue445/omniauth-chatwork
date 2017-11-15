
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "omniauth/chatwork/version"

Gem::Specification.new do |spec|
  spec.name          = "omniauth-chatwork"
  spec.version       = OmniAuth::Chatwork::VERSION
  spec.authors       = ["sue445"]
  spec.email         = ["sue445@sue445.net"]

  spec.summary       = %q{OmniAuth strategy for ChatWork}
  spec.description   = %q{OmniAuth strategy for ChatWork}
  spec.homepage      = "https://github.com/sue445/omniauth-chatwork"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  %w[img/].each do |exclude_dir|
    spec.files.reject! { |filename| filename.start_with?(exclude_dir) }
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "omniauth-oauth2"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 1.0.0"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "dotenv"
  spec.add_development_dependency "faraday_curl"
  spec.add_development_dependency "oauth2", ">= 1.3.0"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "sinatra"
  spec.add_development_dependency "webmock"
end
