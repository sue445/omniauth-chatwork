source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in omniauth-chatwork.gemspec
gemspec

gem "webrick"

# FIXME: Remove this after 1.4.9+ is released
# c.f. https://github.com/oauth-xx/oauth2/issues/572#issuecomment-1045088365
gem "oauth2", github: "oauth-xx/oauth2", branch: "1-4-stable"
