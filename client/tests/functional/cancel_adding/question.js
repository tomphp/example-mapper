casper.test.begin('Cancelling adding a question', function(test) {
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

  casper.initialiseWithState(state);

  casper.waitForElementTextToEqual(
    '#card-story-id',
    'As a test script I want to check behaviour'
  );

  casper.then(function clickNew() {
    this.click('#new-question');
  });

  casper.waitForElementToExist('div#card-new-question', function clickCancelButton() {
    this.click('#card-new-question .card__toolbar-button--cancel');
  });

  casper.waitForElementToExist('button#new-question', function checkButtonReset() {
    test.assertEquals(
      this.fetchText('#new-question'),
      'Add Question',
      'The card returns to an an Add Question button'
    );
  });

  casper.run(function() {
    test.done();
  });
});
