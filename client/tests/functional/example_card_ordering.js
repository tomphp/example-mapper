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

  casper.start(appUrl(), function() {
    this.info('Wait for initial message from the client');
    this.assertMessage(test, 0, {type: 'fetch_update'}, 'A refresh message is sent on connection');
  });

  casper.then(function() {
    this.info('Send initial state');
    this.sendState(state);

    this.info('Wait for state to apply');
    this.waitForElementTextToEqual('#card-story-id', 'Story');
  });

  casper.then(function() {
    test.assertSelectorHasText('#rule-rule1 .example:nth-child(1) .card', 'Example 1');
    test.assertSelectorHasText('#rule-rule1 .example:nth-child(2) .card', 'Example 2');
    test.assertSelectorHasText('#rule-rule1 .example:nth-child(3) .card', 'Example 3');
  });

  casper.run(function() {
    test.done();
  });
});
