class Requirements::Preview::EditionChecker
  include Requirements::Checker

  attr_reader :edition

  CHECKERS = [
    Requirements::Preview::ContentChecker,
  ].freeze

  def initialize(edition)
    @edition = edition
  end

  def check
    CHECKERS.each do |checker|
      issues.push(*checker.call(edition))
    end
  end
end
