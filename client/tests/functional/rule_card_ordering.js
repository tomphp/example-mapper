casper.test.begin('Rule Card Ordering', function(test) {
  var state = {state: {
    story_card: { id: 'story-id', text: 'Story', state: 'saved', position: 0 },
    rules: [
      {
        rule_card: { id: 'rule1', text: 'Rule 1', state: 'saved', position: 1 },
        examples: []
      },
      {
        rule_card: { id: 'rule3', text: 'Rule 3', state: 'saved', position: 3 },
        examples: []
      },
      {
        rule_card: { id: 'rule2', text: 'Rule 2', state: 'saved', position: 2 },
        examples: []
      },
    ],
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
    test.assertSelectorHasText('.rule:nth-child(1) .card', 'Rule 1');
    test.assertSelectorHasText('.rule:nth-child(2) .card', 'Rule 2');
    test.assertSelectorHasText('.rule:nth-child(3) .card', 'Rule 3');
  });

  casper.run(function() {
    test.done();
  });
});
