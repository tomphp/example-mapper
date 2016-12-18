Feature: Create a story

  Scenario: Max creates a new story
    When Max creates a new story "As a writer I want to create a new article"
    Then Max should see a story card containing "As a writer I want to create a new article"
