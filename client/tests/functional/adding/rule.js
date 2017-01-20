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

  casper.start(appUrl()).waitForMessage(0, function() {
    this.sendState(state);
  });

  casper.waitForElementTextToEqual(
    '#card-' + storyCardId,
    'As a test script I want to check behaviour'
  );

  casper.then(function() {
    this.click('#new-rule');
  });

  casper.waitForElementToExist('div#card-new-rule', function() {
    test.assertElementHasClass('#card-new-rule', 'card--editing');
    test.assertEquals(this.getActiveElement().id, 'card-input-new-rule', 'Card input has focus');

    this.sendKeys('#card-new-rule textarea', 'This rule must be created');
    this.click('#card-new-rule .card__toolbar-button--save');
  });

  casper.waitForElementToExist('#card-new-rule.card--saving', function() {
    test.assertEquals(
      this.fetchText('#card-new-rule'),
      'This rule must be created',
      'Card in saving state contains the content'
    );

    test.assertEquals(
      this.getMessage(1),
      {type: 'add_rule', text: 'This rule must be created'},
      'The add message is sent'
    );
  });

  casper.run(function() {
    test.done();
  });
});
