Before do
  @driver = DomainDriver.new
end

When(/^Max creates a new story "([^"]*)"$/) do |text|
  @driver.create_story text
end

Then(/^Max should see a story card containing "([^"]*)"$/) do |text|
  expect(@driver.story_card.text).to eq text
end
