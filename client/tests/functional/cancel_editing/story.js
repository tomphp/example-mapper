casper.test.begin('Cancelling editing a story', function(test) {
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

  casper.then(function clickEdit() {
    this.click('#card-story-id');
  });

  casper.waitForElementToExist('#card-story-id', function clickCancelButton() {
    this.click('#card-story-id .card__toolbar-button--cancel');
  });

  casper.waitForElementToExist('#card-story-id', function checkButtonReset() {
    test.assertEquals(
      this.fetchText('#card-story-id'),
      'As a test script I want to check behaviour',
      'The card shows the original text'
    );
  });

  casper.run(function() {
    test.done();
  });
});
