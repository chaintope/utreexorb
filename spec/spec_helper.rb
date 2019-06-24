require "bundler/setup"
require "utreexo"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def eight_forest
  create_forest(8)
end

def create_forest(size, not_tracking_indexes = [])
  f = Utreexo::Forest.new
  size.times.with_index do |i|
    element = "a0#{i.to_s(16).rjust(2, '0')}00aa00000000000000000000000000000000000000000000000000000000"
    f.add(element, !not_tracking_indexes.include?(i))
  end
  f
end