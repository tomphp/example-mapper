casper.test.begin('Initial loading', function(test) {
  casper.start(appUrl(), function() {
    test.assertEquals(
      this.getMessage(0),
      {type: 'fetch_update'},
      'An update request is sent on initialisation'
    );
  });

  casper.run(function() {
    test.done();
  });
});
