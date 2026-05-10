#!/usr/bin/env ruby

# Script to deploy to itch

DRY_RUN = ARGV.include?("--dry-run")

def butler_push(build)
  butler_cmd_main = "butler push export/bomberfrog-#{build}.zip brettchalupa/bomberfrog:#{build}"
  butler_cmd_alpha = "butler push export/bomberfrog-#{build}.zip brettchalupa/bomberfrog-alpha:#{build}"
  if DRY_RUN
    puts "[DRY RUN] pushing to itch: #{butler_cmd_main}"
  else
    system(butler_cmd_main)
    system(butler_cmd_alpha)
  end
end

puts `usagi export`
butler_push("linux")
butler_push("macos")
butler_push("windows")
butler_push("web")
