var system = require('system')
console.log('Test file: ' + system.args[system.args.length-1]);
var dir = dirname(system.args[system.args.length-1]);
var app = 'file://' + dir + '/app/test.html';

console.log('Loading ' + app);

casper.test.begin('Initial loading', function(test) {
    var storyCardId = '8d85e649-4105-4831-9dad-d1cceb64bbaf',
      questionCardId = 'e82e0d5c-9278-4a3a-9852-1a511fdf2ee0',
      state = {
        state: {
          story_card: {
            id: storyCardId,
            text: 'As a test script I want to check behaviour',
            state: 'saved',
            position: 0
          },
          rules: [],
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

  casper.start(app, function() {
    assertMessage.call(this, test, 0, {type: 'fetch_update'}, 'A refresh message is sent on connection');
  });

  casper.then(function() {
    sendState.call(this, state);

    this.waitFor(function() {
      return this.fetchText('#card-' + storyCardId) === 'As a test script I want to check behaviour';
    }, function() {
    }, function() {
      this.echo('Update didn\'t apply.').exit();
    });
  });

  casper.then(function() {
    test.assertEquals(
        this.fetchText('#card-' + storyCardId),
        'As a test script I want to check behaviour',
        'Story card contains story text');

    var cardInfo = this.getElementInfo('#card-' + storyCardId);
    var classes = cardInfo.attributes['class'].split(' ');
    test.assert(classes.indexOf('card--story') > -1, 'Story card has class card--story');
  });

  casper.then(function() {
    test.assertEquals(
        this.fetchText('#card-' + questionCardId),
        'Does this card appear?',
        'Question card contains question text');

    var cardInfo = this.getElementInfo('#card-' + questionCardId);
    var classes = cardInfo.attributes['class'].split(' ');
    test.assert(classes.indexOf('card--question') > -1, 'Question card has class card--question');
  });

  casper.run(function() {
    test.done();
  });
});

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

  casper.start(app, function() {
    assertMessage.call(this, test, 0, {type: 'fetch_update'}, 'A refresh message is sent on connection');
  });

  casper.then(function() {
    sendState.call(this, state);

    this.waitFor(function() {
      return this.fetchText('#card-' + storyCardId) === 'As a test script I want to check behaviour';
    }, function() {
    }, function() {
      this.echo('Update didn\'t apply.').exit();
    });
  });

  casper.then(function() {
    this.click('#new-rule');

    this.waitFor(function() {
      return this.exists('div#new-rule');
    }, function() {
      var cardInfo = this.getElementInfo('#new-rule');
      var classes = cardInfo.attributes['class'].split(' ');
      test.assert(classes.indexOf('card--editing') > -1, 'New rule card has class card--editing');

      this.sendKeys('#new-rule textarea', 'This rule must be created', {keepFocus: true});
      this.sendKeys('#new-rule textarea', casper.page.event.key.Tab , {keepFocus: true});
    }, function() {
      this.echo('Click didn\'t apply.').exit();
    });
  });

  /*
  casper.then(function() {
    this.waitFor(function() {
      var cardInfo = this.getElementInfo('#new-rule');
      this.echo(cardInfo.attributes['class']);

      return this.exists('#new-rule.card--saving');
    }, function() {
    }, function() {
      this.echo('Card state didn\'t updated').exit();
    });
  });
  */

  casper.then(function() {
    assertMessage.call(
      this, test, 1,
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

  casper.start(app, function() {
    assertMessage.call(this, test, 0, {type: 'fetch_update'}, 'A refresh message is sent on connection');
  });

  casper.then(function() {
    sendState.call(this, state);

    this.waitFor(function() {
      return this.fetchText('#card-' + storyCardId) === 'As a test script I want to check behaviour';
    }, function() {
    }, function() {
      this.echo('Update didn\'t apply.').exit();
    });
  });

  casper.then(function() {
    this.click('#new-question');

    this.waitFor(function() {
      return this.exists('div#new-question');
    }, function() {
      var cardInfo = this.getElementInfo('#new-question');
      var classes = cardInfo.attributes['class'].split(' ');
      test.assert(classes.indexOf('card--editing') > -1, 'New question card has class card--editing');

      this.sendKeys('#new-question textarea', 'Will this question be created?', {keepFocus: true});
      this.sendKeys('#new-question textarea', casper.page.event.key.Tab , {keepFocus: true});
    }, function() {
      this.echo('Click didn\'t apply.').exit();
    });
  });

  /*
  casper.then(function() {
    this.waitFor(function() {
      var cardInfo = this.getElementInfo('#new-question');
      this.echo(cardInfo.attributes['class']);

      return this.exists('#new-question.card--saving');
    }, function() {
    }, function() {
      this.echo('Card state didn\'t updated').exit();
    });
  });
  */

  casper.then(function() {
    assertMessage.call(
      this, test, 1,
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

function dirname(path) {
  return path.replace(/\\/g,'/').replace(/\/[^\/]*$/, '');;
}

function sendState(state) {
  this.evaluate(function(state) {
    sendMessage(state);
  }, {state: state});
}

function assertMessage(test, num, expected, description) {
  function getMessage(num) {
    return this.evaluate(function(num) {
      return messages[num];
    }, num);
  }

  this.waitFor(
    function check() {
      return getMessage.call(this, num);
    },
    function() {
      test.assertEquals(
        JSON.parse(getMessage.call(this, num)),
        expected,
        description
      );
    },
    function timeout() {
      this.echo('Timed out').exit();
    }
  );
};