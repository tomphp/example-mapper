Before do
  @users = {}
  @driver = CapybaraDriver.new
end

Given(/^(\w+) has created a new story$/) do |user|
  step %(#{user} creates a new story "Example Story")
end

When(/^(\w+) creates a new story "([^"]*)"$/) do |user, text|
  @driver.create_story(user, text)
end

Given(/^(\w+) has joined (\w+)'s story$/) do |user, owner|
  @users[user] = DomainDriver.join_story(@users[owner].story.id)
end

When(/^(\w+) adds a rule "([^"]*)"$/) do |user, text|
  @users[user].add_rule(text)
end

Then(/^(\w+) should see a story card containing "([^"]*)"$/) do |text|
  expect(@users[user].story.story_card.text).to eq text
end

Then(/^(\w+) should see a new rule card containing "([^"]*)"$/) do |user, text|
  expect(@users[user].story.rules.first.text).to eq text
end
