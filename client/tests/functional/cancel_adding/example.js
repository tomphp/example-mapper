casper.test.begin('Cancelling adding a question', function(test) {
  var state = { state: {
    story_card: {
      id: 'story-id',
      text: 'As a test script I want to check behaviour',
      state: 'saved',
      position: 0
    },
    rules: [{
      rule_card: {
        id: 'rule-id',
        text: 'This rule must be shown',
        state: 'saved',
        position: 0
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

  casper.then(function clickNew() {
    this.click('#new-example-rule-id');
  });

  casper.waitForElementToExist('div#card-new-example-rule-id', function clickCancelButton() {
    this.click('#card-new-example-rule-id .card__toolbar-button--cancel');
  });

  casper.waitForElementToExist('button#new-example-rule-id', function checkButtonReset() {
    test.assertEquals(
      this.fetchText('#new-example-rule-id'),
      'Add Example',
      'The card returns to an an Add Example button'
    );
  });

  casper.run(function() {
    test.done();
  });
});
