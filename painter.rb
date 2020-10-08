#!/usr/bin/env ruby

require 'rugged'
require 'date'

# EMAIL = ENV['GIT_COMITTER_EMAIL']
# USERNAME = ENV['GIT_COMMITTER_NAME']

EMAIL = "paul.lambert@linux.com"
USERNAME = "Paul Lambert"
NUM_PAST_DAYS = 365*2 # two years of history

repo = Rugged::Repository.new('.')

NUM_PAST_DAYS.times do |x|

  daily_commits = rand(1..15)
  daily_commits.times do |y|
    time_stamp = Time.now - x*24*60*60 - y*10

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
