casper.test.begin('Cancelling editing a rule', function(test) {
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

  casper.then(function clickEdit() {
    this.click('#card-rule-id');
  });

  casper.waitForElementToExist('#card-rule-id', function clickCancelButton() {
    this.click('#card-rule-id .card__toolbar-button--cancel');
  });

  casper.waitForElementToExist('#card-rule-id', function checkButtonReset() {
    test.assertEquals(
      this.fetchText('#card-rule-id'),
      'This rule must be shown',
      'The card shows the original text'
    );
  });

  casper.run(function() {
    test.done();
  });
});
