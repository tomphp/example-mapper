casper.test.begin('Rule cards render correctly', function(test) {
  var state = { state: {
    story_card: {
      id: 'story-id',
      text: 'As a test script I want to check behaviour',
      state: 'saved',
      position: 0,
      version: 1,
    },
    rules: [{
      rule_card: {
        id: 'rule-id',
        text: 'This rule must be shown',
        state: 'saved',
        position: 0,
        version: 1,
      },
      examples: []
    }],
    questions:[],
  } };

  casper.initialiseWithState(state);

  casper.waitForElementTextToEqual(
    '#card-story-id',
    'As a test script I want to check behaviour'
  );

  casper.then(function() {
    this.info('Check rule cards render correctly');

    test.assertEquals(
      this.fetchText('#card-rule-id'),
      'This rule must be shown',
      'Rule card contains rule text'
    );

    test.assertElementHasClass('#card-rule-id', 'card--rule');
  });

  casper.run(function() {
    test.done();
  });
});
