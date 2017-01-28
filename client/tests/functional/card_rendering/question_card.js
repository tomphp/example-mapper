casper.test.begin('Question cards render correctly', function(test) {
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

  casper.then(function() {
    this.info('Check question cards render correctly');

    test.assertEquals(
      this.fetchText('#card-question-id'),
      'Does this card appear?',
      'Question card contains question text'
    );

    test.assertElementHasClass('#card-question-id', 'card--question');
  });

  casper.run(function() {
    test.done();
  });
});
