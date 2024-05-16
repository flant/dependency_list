# frozen_string_literal: true

require 'pry-byebug'

RSpec.configure do |config|
  config.example_status_persistence_file_path = "#{__dir__}/examples.txt"
end

require_relative '../lib/dependency_list'
