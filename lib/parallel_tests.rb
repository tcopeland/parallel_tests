require "parallel"
require "parallel_tests/railtie" if defined? Rails::Railtie

module ParallelTests
  autoload :CLI, "parallel_tests/cli"
  autoload :VERSION, "parallel_tests/version"
  autoload :Grouper, "parallel_tests/grouper"

  def self.determine_number_of_processes(count)
    [
      count,
      ENV["PARALLEL_TEST_PROCESSORS"],
      Parallel.processor_count
    ].detect{|c| not c.to_s.strip.empty? }.to_i
  end

  # copied from http://github.com/carlhuda/bundler Bundler::SharedHelpers#find_gemfile
  def self.bundler_enabled?
    return true if Object.const_defined?(:Bundler)

    previous = nil
    current = File.expand_path(Dir.pwd)

    until !File.directory?(current) || current == previous
      filename = File.join(current, "Gemfile")
      return true if File.exists?(filename)
      current, previous = File.expand_path("..", current), current
    end

    false
  end

  def self.first_process?
    !ENV["TEST_ENV_NUMBER"] || ENV["TEST_ENV_NUMBER"].to_i == 0
  end

  def self.wait_for_other_processes_to_finish
    return unless ENV["TEST_ENV_NUMBER"]
    sleep 1 until number_of_running_processes <= 1
  end

  # Fun fact: this includes the current process if it's run via parallel_tests
  def self.number_of_running_processes
    result = Dir.glob('tmp/.process.*').size
  end
end
