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

  casper.start(appUrl(), function() {
    this.info('Wait for initial message from the client');
    this.assertMessage(test, 0, {type: 'fetch_update'}, 'A refresh message is sent on connection');
  });

  casper.then(function() {
    this.info('Send initial state');
    this.sendState(state);

    this.info('Wait for state to apply');
    this.waitForElementTextToEqual('#card-' + storyCardId, 'As a test script I want to check behaviour');
  });

  casper.then(function() {
    this.info('Click the Add Question button');
    this.click('#new-question');

    this.info('Wait for the new card to appear');
    this.waitForElementToExist('div#card-new-question');
  });

  casper.then(function() {
    test.assertElementHasClass('#card-new-question', 'card--editing');

    test.assertEquals(this.getActiveElement().id, 'card-input-new-question', 'Check the card input has focus');

    this.info('Enter the new card content');
    this.sendKeys('#card-new-question textarea', 'Will this question be created?', {keepFocus: true});

    this.info('Press the TAB key');
    this.sendKeys('#card-new-question textarea', casper.page.event.key.Tab , {keepFocus: true});

    this.info('Wait for the card to have the saving style');
    this.waitForElementToExist('#card-new-question.card--saving');
  });

  casper.then(function() {
    this.info('Confirm an add_question message was sent');
    this.assertMessage(
      test, 1,
      {type: 'add_question', text: 'Will this question be created?'},
      'The add message is sent'
    );
  });

  // send reply

  // check new card

  casper.run(function() {
    test.done();
  });
});
