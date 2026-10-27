# frozen_string_literal: true

require_relative "lib/chicago_charter_bus_rental"

Gem::Specification.new do |s|
  s.name          = "chicago_charter_bus_rental"
  s.version       = ChicagoCharterBusRental::VERSION
  s.summary       = "Chicago group charter planner: how many vehicles does a headcount need?"
  s.description   = "Recommends the fewest vehicles for a Chicago group charter headcount using the " \
                    "Chicago Charter Bus Rental fleet seat sizes, with spare-seat counts and a " \
                    "late-additions headcount buffer. Library only, no dependencies."
  s.authors       = ["nbkdevs"]
  s.email         = "info@chicagosupercoach.com"
  s.homepage      = "https://chicagosupercoachbus.com/"
  s.license       = "MIT"
  s.required_ruby_version = ">= 2.7"
  s.files         = Dir["lib/**/*.rb", "README.md", "LICENSE"]
  s.require_paths = ["lib"]
  s.metadata      = {
    "homepage_uri" => "https://chicagosupercoachbus.com/",
    "source_code_uri" => "https://github.com/nbkdevs/chicago-super/tree/main/publish/chicago-charter-bus-rental/rubygems",
    "bug_tracker_uri" => "https://github.com/nbkdevs/chicago-super/issues"
  }
end
