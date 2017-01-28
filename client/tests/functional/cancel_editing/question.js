casper.test.begin('Cancelling editing a question', function(test) {
  var state = { state: {
    story_card: {
      id: 'story-id',
      text: 'As a test script I want to check behaviour',
      state: 'saved',
      position: 0,
      version: 1,
    },
    rules: [],
    questions:[
      {
        id: 'question-id',
        text: 'Does this card appear?',
        state: 'saved',
        position: 0,
        version: 1,
      },
    ],
  } };

  casper.initialiseWithState(state);

  casper.waitForElementTextToEqual(
    '#card-story-id',
    'As a test script I want to check behaviour'
  );

  casper.then(function clickEdit() {
    this.click('#card-question-id');
  });

  casper.waitForElementToExist('#card-question-id', function clickCancelButton() {
    this.click('#card-question-id .card__toolbar-button--cancel');
  });

  casper.waitForElementToExist('#card-question-id', function checkButtonReset() {
    test.assertEquals(
      this.fetchText('#card-question-id'),
      'Does this card appear?',
      'The card shows the original text'
    );
  });

  casper.run(function() {
    test.done();
  });
});
