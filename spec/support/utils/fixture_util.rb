module FixtureUtil
  def fixture(fixture_name)
    spec_dir.join("support", "fixtures", "#{fixture_name}").read
  end
end
