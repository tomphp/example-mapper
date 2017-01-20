casper.test.begin('Adding a Question', function(test) {
  var storyCardId = '8d85e649-4105-4831-9dad-d1cceb64bbaf',
    state = {
      state: {
        story_card: {
          id: storyCardId,
          text: 'As a test script I want to check behaviour',
          state: 'saved',
          position: 0
        },
        rules: [],
        questions:[],
      }
    };

  casper.start(appUrl()).waitForMessage(0, function() {
    this.sendState(state);
  });

  casper.waitForElementTextToEqual(
    '#card-' + storyCardId,
    'As a test script I want to check behaviour'
  );

  casper.then(function() {
    this.click('#new-question');
  });

  casper.waitForElementToExist('div#card-new-question', function() {
    test.assertElementHasClass('#card-new-question', 'card--editing');
    test.assertEquals(this.getActiveElement().id, 'card-input-new-question', 'Check the card input has focus');

    this.sendKeys('#card-new-question textarea', 'Will this question be created?', {keepFocus: true});
    this.click('#card-new-question .card__toolbar-button--save');
  });

  casper.waitForElementToExist('#card-new-question.card--saving', function() {
    test.assertEquals(
      this.fetchText('#card-new-question .card__text'),
      'Will this question be created?',
      'Card in saving state contains the content'
    );

    test.assertEquals(
      this.getMessage(1),
      {type: 'add_question', text: 'Will this question be created?'},
      'The add message is sent'
    );
  });

  casper.run(function() {
    test.done();
  });
});
