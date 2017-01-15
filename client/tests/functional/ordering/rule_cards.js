casper.test.begin('Rule card ordering', function(test) {
  var state = {state: {
    story_card: { id: 'story-id', text: 'Story', state: 'saved', position: 0 },
    rules: [
      {
        rule_card: { id: 'rule1', text: 'Rule 1', state: 'saved', position: 1 },
        examples: [],
      },
      {
        rule_card: { id: 'rule3', text: 'Rule 3', state: 'saved', position: 3 },
        examples: [],
      },
      {
        rule_card: { id: 'rule2', text: 'Rule 2', state: 'saved', position: 2 },
        examples: [],
      },
    ],
    questions:[],
  }};

  casper.start(appUrl()).waitForMessage(0, function() {
    this.sendState(state);
  });

  casper.waitForElementTextToEqual('#card-story-id', 'Story', function() {
    test.assertSelectorHasText('.rule:nth-child(1) .card', 'Rule 1');
    test.assertSelectorHasText('.rule:nth-child(2) .card', 'Rule 2');
    test.assertSelectorHasText('.rule:nth-child(3) .card', 'Rule 3');
  });

  casper.run(function() {
    test.done();
  });
});
