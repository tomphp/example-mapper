casper.test.begin('Example cards render correctly', function(test) {
  var state = { state: {
    story_card: {
      id: 'story-id',
      text: 'As a test script I want to check behaviour',
      state: 'saved',
      position: 0
    },
    rules: [
      {
        rule_card: {id: 'rule-id', text: 'This rule must be shown', state: 'saved', position: 0 },
        examples: [
          {
            id: 'example-id',
            text: 'The one where this example appears',
            state: 'saved',
            position: 0
          }
        ]
      },
    ],
    questions:[],
  }};

  casper.initialiseWithState(state);

  casper.waitForElementTextToEqual(
    '#card-story-id',
    'As a test script I want to check behaviour'
  );

  casper.then(function() {
    this.info('Check example cards render correctly');

    test.assertEquals(
      this.fetchText('#card-example-id'),
      'The one where this example appears',
      'Example card contains example text'
    );

    test.assertElementHasClass('#card-example-id', 'card--example');
  });

  casper.run(function() {
    test.done();
  });
});
