casper.test.begin('Cancelling adding a rule', function(test) {
  var state = { state: {
    story_card: {
      id: 'story-id',
      text: 'As a test script I want to check behaviour',
      state: 'saved',
      position: 0
    },
    rules: [],
    questions:[],
  } };

  casper.start(appUrl()).waitForMessage(0, function sendState() {
    this.sendState(state);
  });

  casper.waitForElementTextToEqual(
    '#card-story-id',
    'As a test script I want to check behaviour'
  );

  casper.then(function clickNew() {
    this.click('#new-rule');
  });

  casper.waitForElementToExist('div#card-new-rule', function clickCancelButton() {
    this.click('#card-new-rule .card__toolbar-button--cancel');
  });

  casper.waitForElementToExist('button#new-rule', function checkButtonReset() {
    test.assertEquals(
      this.fetchText('#new-rule'),
      'Add Rule',
      'The card returns to an an Add Rule button'
    );
  });

  casper.run(function() {
    test.done();
  });
});
