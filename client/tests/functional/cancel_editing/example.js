casper.test.begin('Cancelling editing a example', function(test) {
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
      examples: [ {
        id: 'example-id',
        text: 'The one where this example appears',
        state: 'saved',
        position: 0
      }]
    }],
    questions:[],
  } };

  casper.start(appUrl()).waitForMessage(0, function sendState() {
    this.sendState(state);
  });

  casper.waitForElementTextToEqual(
    '#card-story-id',
    'As a test script I want to check behaviour'
  );

  casper.then(function clickEdit() {
    this.click('#card-example-id');
  });

  casper.waitForElementToExist('#card-example-id', function clickCancelButton() {
    this.click('#card-example-id .card__toolbar-button--cancel');
  });

  casper.waitForElementToExist('#card-example-id', function checkButtonReset() {
    test.assertEquals(
      this.fetchText('#card-example-id'),
      'The one where this example appears',
      'The card shows the original text'
    );
  });

  casper.run(function() {
    test.done();
  });
});
