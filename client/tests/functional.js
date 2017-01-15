var system = require('system')

function appUrl() {
  function dirname(path) {
    return path.replace(/\\/g,'/').replace(/\/[^\/]*$/, '');;
  }

  console.log('Test file: ' + system.args[system.args.length-1]);
  var dir = dirname(system.args[system.args.length-1]);
  var app = 'file://' + dir + '/app/test.html';

  console.log('Loading: ' + app);

  return app;
}

casper.test.assertElementHasClass = function(selector, className) {
  this.assert(
    casper.getClassesFor(selector).indexOf(className) > -1,
    selector + ' has class ' + className
  );
};

casper.sendState = function(state) {
  this.evaluate(function(state) {
    sendMessage(state);
  }, {state: state});
};

casper.getActiveElement = function() {
  return this.evaluate(function() {
    return document.activeElement;
  });
};

casper.assertMessage = function(test, num, expected, description) {
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

casper.waitForElementTextToEqual = function(selector, text) {
  return this.waitFor(function() {
    return this.fetchText(selector) === text;
  }, function() {
  }, function() {
    this.echo('Timed out while waitinf for' + selector + ' to contain "' + text + '"').exit();
  });
};

casper.waitForElementToExist = function (selector) {
  return this.waitFor(function() {
    return this.exists(selector);
  }, function() {
  }, function() {
    this.echo('Timed out waiting to find ' + selector).exit();
  });
};

casper.getClassesFor = function(selector) {
  var cardInfo = this.getElementInfo(selector);
  return cardInfo.attributes['class'].split(' ');
};

casper.info = function(message) {
  this.echo('STEP ' + message);
};
