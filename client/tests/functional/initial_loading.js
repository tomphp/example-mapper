casper.test.begin('Initial loading', function(test) {
  var storyCardId = '8d85e649-4105-4831-9dad-d1cceb64bbaf',
    questionCardId = 'e82e0d5c-9278-4a3a-9852-1a511fdf2ee0',
    ruleCardId = '3b6464c5-4c2b-4530-bb28-ab0734b99b16',
    exampleCardId = 'de1ede0c-dae3-41f0-b284-2d5b10728001',
    state = {
      state: {
        story_card: {
          id: storyCardId,
          text: 'As a test script I want to check behaviour',
          state: 'saved',
          position: 0
        },
        rules: [
          {
            rule_card: {
              id: ruleCardId,
              text: 'This rule must be shown',
              state: 'saved',
              position: 0
            },
            examples: [
              {
                id: exampleCardId,
                text: 'The one where this example appears',
                state: 'saved',
                position: 0
              }
            ]
          },
        ],
        questions:[
          {
            id: questionCardId,
            text: 'Does this card appear?',
            state: 'saved',
            position: 0
          },
        ],
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
    this.info('Check story cards render correctly');

    test.assertEquals(
      this.fetchText('#card-' + storyCardId),
      'As a test script I want to check behaviour',
      'Story card contains story text'
    );

    test.assertElementHasClass('#card-' + storyCardId, 'card--story');
  });

  casper.then(function() {
    this.info('Check question cards render correctly');

    test.assertEquals(
      this.fetchText('#card-' + questionCardId),
      'Does this card appear?',
      'Question card contains question text'
    );

    test.assertElementHasClass('#card-' + questionCardId, 'card--question');
  });

  casper.then(function() {
    this.info('Check rule cards render correctly');

    test.assertEquals(
      this.fetchText('#card-' + ruleCardId),
      'This rule must be shown',
      'Rule card contains rule text'
    );

    test.assertElementHasClass('#card-' + ruleCardId, 'card--rule');
  });

  casper.then(function() {
    this.info('Check example cards render correctly');

    test.assertEquals(
      this.fetchText('#card-' + exampleCardId),
      'The one where this example appears',
      'Example card contains example text'
    );

    test.assertElementHasClass('#card-' + exampleCardId, 'card--example');
  });

  casper.run(function() {
    test.done();
  });
});
