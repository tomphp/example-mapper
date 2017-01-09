var system = require('system')
console.log('Test file: ' + system.args[system.args.length-1]);
var dir = dirname(dirname(system.args[system.args.length-1]));
var app = 'file://' + dir + '/test.html';

console.log('Loading ' + app);

function dirname(path) {
  return path.replace(/\\/g,'/').replace(/\/[^\/]*$/, '');;
}

function assertMessage(context, test, num, expected, description) {
  function getMessage(num) {
    return context.evaluate(function(num) {
      return messages[num];
    }, num);
  }

  context.waitFor(
    function check() {
      return getMessage(num);
    },
    function() {
      test.assertEquals(
        JSON.parse(getMessage(num)),
        {type: 'fetch_update'},
        description
      );
    },
    function timeout() {
      context.echo('Timed out').exit();
    }
  );
};

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
    assertMessage(this, test, 0, {type: 'fetch_update'}, 'A refresh message is sent on connection');
  });

  casper.then(function() {
    this.evaluate(function(state) {
      sendMessage(state);
    }, {state: state});

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
