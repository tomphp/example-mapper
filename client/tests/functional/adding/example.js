casper.test.begin('Adding an Example', function(test) {
    state = {
      state: {
        story_card: {
          id: 'story-id',
          text: 'As a test script I want to check behaviour',
          state: 'saved',
          position: 0
        },
        rules: [{
          rule_card: { id: 'rule-id', text: 'This rule must contain examples', state: 'saved', position: 1 },
          examples: [],
        }],
        questions:[],
      }
    };

  casper.initialiseWithState(state);

  casper.waitForElementTextToEqual(
    '#card-story-id',
    'As a test script I want to check behaviour'
  );

  casper.then(function() {
    this.click('#new-example-rule-id');
  });

  casper.waitForElementToExist('div#card-new-example-rule-id', function() {
    test.assertElementHasClass('#card-new-example-rule-id', 'card--editing');
    test.assertEquals(this.getActiveElement().id, 'card-input-new-example-rule-id', 'Card input has focus');

    this.sendKeys('#card-new-example-rule-id textarea', 'This example is created', {keepFocus: true});
    this.click('#card-new-example-rule-id .card__toolbar-button--save');
  });

  casper.waitForElementToExist('#card-new-example-rule-id.card--saving', function() {
    test.assertEquals(
      this.fetchText('#card-new-example-rule-id .card_text'),
      'This example is created',
      'Card in saving state contains the content'
    );

    test.assertEquals(
      this.getMessage(1),
      {type: 'add_example', rule_id: 'rule-id', text: 'This example is created'},
      'The add message is sent'
    );
  });

  casper.run(function() {
    test.done();
  });
});
