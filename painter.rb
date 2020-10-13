#!/usr/bin/env ruby

require 'rugged'
require 'date'

# TODO Switch to using argv maybe
EMAIL = "paul.lambert@linux.com"
USERNAME = "Paul Lambert"
PATH = "/home/paul/code/fake-commits"
NUM_PAST_DAYS = 365*6 # six years of history

repo = Rugged::Repository.new(PATH)

NUM_PAST_DAYS.times do |x|

  time_stamp = Time.now - x*24*60*60

  if time_stamp.saturday?
    daily_commits = rand(0..6)
  elsif time_stamp.sunday?
    daily_commits = rand(0..3)
  else
    daily_commits = rand(11..31)
  end

  daily_commits.times do |y|
    time_stamp -= y * 10

    oid = repo.write("This is a phony timestamp: #{time_stamp}", :blob)
    index = repo.index
    index.read_tree(repo.head.target.tree)
    index.add(:path => "phony-dates.md", :oid=>oid, :mode=>0100644)

    options = {}
    options[:tree] = index.write_tree(repo)

    options[:author] = {
      :email => EMAIL,
      :name => USERNAME,
      :time => time_stamp
    }

    options[:comitter] = {
      :email => EMAIL,
      :name => USERNAME,
      :time => time_stamp
    }

    options[:message] ||= "Making a commit via Rugged!"
    options[:parents] = repo.empty? ? [] : [ repo.head.target ].compact
    options[:update_ref] = 'HEAD'

    Rugged::Commit.create(repo, options)
  end
end
