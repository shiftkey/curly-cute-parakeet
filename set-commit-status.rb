require 'Octokit'

token = ENV['OCTOKIT_ACCESS_TOKEN']

if token.nil? || token.empty? then
  puts "You need to set a personal access token to continue"
  puts "For example:"
  puts "> export OCTOKIT_ACCESS_TOKEN=<some value here>"
  exit
end

client = Octokit::Client.new(:access_token => token)

puts "Press CTRL+C at any time to cancel..."
puts

puts "Which repository (specify owner/repository format):"
STDOUT.flush
repository = gets.chomp

begin
  found_repository = client.repository(repository)
rescue
  puts "Could not find repository " + repository
  puts "Exiting..."
  exit
end

puts "Found the repository!\n\n"

puts "Enter the commit SHA you want to update (find any old commit SHA):"
STDOUT.flush
commit_sha = gets.chomp

begin
  found_commit = client.commit(repository, commit_sha)
rescue
  puts "Could not find commit " + commit_sha
  puts "Exiting..."
  exit
end

puts "Found the commit!\n\n"

valid_statuses = [ 'pending', 'success', 'error', 'failure' ]

puts "What status to use (pending|success|error|failure):"
STDOUT.flush
status = gets.chomp

if !valid_statuses.any? { |s| s == status } then
  puts "Text entered is not a valid status: " + status
  puts "Exiting..."
  exit
end


begin
  info = {
    :target_url => 'http://github.com',
    :context => 'default'
  }
  status = client.create_status(repository, found_commit.sha, status, info)
rescue
  puts "Unable to create status\n"
  raise
end

puts "Great success!!!"
