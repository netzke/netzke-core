Feature: Actions
  In order to value
  As a role
  I want feature

@javascript
Scenario: Making seven consecutive endpoint calls within 10ms batches to one XHR
  When I go to the ServerCounter test page
  And I press "Count seven times"
  Then total requests made should be 1

@javascript
Scenario: Doing two calls to different endpoints preserves the order in request and response
  When I go to the ServerCounter test page
  And I press "Do ordered"
# "Second." is the indication that the result was applied to the client in the right order  
# "2" is the indication that the request were processed in the right order on the server side  
  Then I should see "Second. 2"