Feature: Add a rule

  Scenario: The one where max adds a new rule
    Given Max has created a new story
    And Mia has joined Max's story
    When Max adds a rule "Only writers can create new articles"
    Then Max should see a new rule card containing "Only writers can create new articles"
    And Mia should see a new rule card containing "Only writers can create new articles"
