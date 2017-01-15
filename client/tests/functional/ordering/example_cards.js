casper.test.begin('Example card ordering', function(test) {
  var state = {state: {
    story_card: { id: 'story-id', text: 'Story', state: 'saved', position: 0 },
    rules: [{
      rule_card: { id: 'rule1', text: 'Rule 1', state: 'saved', position: 1 },
      examples: [
        { id: 'example3', text: 'Example 3', state: 'saved', position: 3 },
        { id: 'example1', text: 'Example 1', state: 'saved', position: 1 },
        { id: 'example2', text: 'Example 2', state: 'saved', position: 2 },
      ]
    }],
    questions:[],
  }};

  casper.start(appUrl()).waitForMessage(0, function() {
    this.sendState(state);
  });

  casper.waitForElementTextToEqual('#card-story-id', 'Story', function() {
    test.assertSelectorHasText('#rule-rule1 .example:nth-child(1) .card', 'Example 1');
    test.assertSelectorHasText('#rule-rule1 .example:nth-child(2) .card', 'Example 2');
    test.assertSelectorHasText('#rule-rule1 .example:nth-child(3) .card', 'Example 3');
  });

  casper.run(function() {
    test.done();
  });
});
