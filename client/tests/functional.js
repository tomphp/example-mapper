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

casper.getMessage = function(num) {
  var json = this.evaluate(function(num) {
    return messages[num];
  }, num);

  if (typeof json === 'undefined') {
    return undefined;
  }

  return JSON.parse(json);
}

casper.waitForMessage = function(num, success, failure) {
  function getMessage(num) {
    return this.evaluate(function(num) {
      return messages[num];
    }, num);
  }

  return this.waitFor(
    function check() {
      return getMessage.call(this, num);
    },
    success,
    failure
  );
};

casper.waitForElementTextToEqual = function(selector, text, success, failure) {
  return this.waitFor(
    function() {
      return this.fetchText(selector) === text;
    },
    success,
    failure
  );
};

casper.waitForElementToExist = function (selector, success, failure) {
  return this.waitFor(
    function() {
      return this.exists(selector);
    },
    success,
    failure
  );
};

casper.getClassesFor = function(selector) {
  var cardInfo = this.getElementInfo(selector);
  return cardInfo.attributes['class'].split(' ');
};

casper.info = function(message) {
  this.echo('STEP ' + message);
};
