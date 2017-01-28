casper.test.begin('Initial loading', function(test) {
  casper.start(appUrl(), function setClientId() {
    this.sendState({
      story_id: 'story-id',
      type: 'set_client_id',
      client_id: 'client-id',
      from: 'client-id',
      client_request_no: 0,
    });
  });

  casper.waitForMessage(0, function waitForRefreshRequest() {
    test.assertEquals(
      this.getMessage(0),
      {request_no: 0, type: 'fetch_update'},
      'An update request is sent on initialisation'
    );
  });

  casper.run(function() {
    test.done();
  });
});
