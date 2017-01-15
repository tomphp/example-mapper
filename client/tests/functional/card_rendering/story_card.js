casper.test.begin('Story cards render correctly', function(test) {
  var
    state = {
      state: {
        story_card: {
          id: 'story-id',
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
    '#card-story-id',
    'As a test script I want to check behaviour'
  );

  casper.then(function() {
    this.info('Check story cards render correctly');

    test.assertEquals(
      this.fetchText('#card-story-id'),
      'As a test script I want to check behaviour',
      'Story card contains story text'
    );

    test.assertElementHasClass('#card-story-id', 'card--story');
  });

  casper.run(function() {
    test.done();
  });
});
