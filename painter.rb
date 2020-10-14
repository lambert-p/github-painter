#!/usr/bin/env ruby

require 'date'
require 'rugged'
require 'yaml'

# Load in user config

yaml_config_opts = YAML.load_file('./config.yml')
EMAIL = yaml_config_opts["gh_email"]
USERNAME = yaml_config_opts["gh_username"]
PATH = yaml_config_opts["path"] 
NUM_PAST_DAYS = yaml_config_opts["num_days"].to_i


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

    options[:message] ||= "Making a commit at #{time_stamp}"
    options[:parents] = repo.empty? ? [] : [ repo.head.target ].compact
    options[:update_ref] = 'HEAD'

    Rugged::Commit.create(repo, options)
  end
end
