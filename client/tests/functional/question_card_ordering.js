casper.test.begin('Question card ordering', function(test) {
  var state = {state: {
    story_card: { id: 'story-id', text: 'Story', state: 'saved', position: 0 },
    rules: [],
    questions:[
      { id: 'question1', text: 'Question 1', state: 'saved', position: 1 },
      { id: 'question3', text: 'Question 3', state: 'saved', position: 3 },
      { id: 'question2', text: 'Question 2', state: 'saved', position: 2 },
    ],
  }};

  casper.start(appUrl(), function() {
    this.info('Wait for initial message from the client');
    this.assertMessage(test, 0, {type: 'fetch_update'}, 'A refresh message is sent on connection');
  });

  casper.then(function() {
    this.info('Send initial state');
    this.sendState(state);

    this.info('Wait for state to apply');
    this.waitForElementTextToEqual('#card-story-id', 'Story');
  });

  casper.then(function() {
    test.assertSelectorHasText('.question:nth-child(1) .card', 'Question 1');
    test.assertSelectorHasText('.question:nth-child(2) .card', 'Question 2');
    test.assertSelectorHasText('.question:nth-child(3) .card', 'Question 3');
  });

  casper.run(function() {
    test.done();
  });
});
