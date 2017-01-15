casper.test.begin('Adding a Rule', function(test) {
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
    this.info('Click the Add Rule button');
    this.click('#new-rule');

    this.info('Wait for the new card to appear');
    this.waitForElementToExist('div#card-new-rule');
  });

  casper.then(function() {
    test.assertElementHasClass('#card-new-rule', 'card--editing');

    test.assertEquals(this.getActiveElement().id, 'card-input-new-rule', 'Card input has focus');

    this.info('Enter the new card content');
    this.sendKeys('#card-new-rule textarea', 'This rule must be created', {keepFocus: true});

    this.info('Press the TAB key');
    this.sendKeys('#card-new-rule textarea', casper.page.event.key.Tab , {keepFocus: true});

    this.info('Wait for the card to have the saving style');
    this.waitForElementToExist('#card-new-rule.card--saving');
  });

  casper.then(function() {
    this.assertMessage(
      test, 1,
      {type: 'add_rule', text: 'This rule must be created'},
      'The add message is sent'
    );
  });

  // send reply

  // check new card

  casper.run(function() {
    test.done();
  });
});
