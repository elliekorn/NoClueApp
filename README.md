#  No Clue App

This is the source code the the No Clue app on the iOS App Store.

If you'd like to make contributions, I'll be happy to update the app on the App Store with them.

## Possible enhancements

Flexibility:
1. Allow editing number of cards held by each player after starting game (if the user recorded them incorrectly and only noticed late)
1. Allow entering outside-of-game information (player has X, player does not have X), as some editions' rules explicitly allow looking at another player's notes if they don't hide them

More corner-case inferences:
1. If player has only one unknown card left and we have constraints ABC and CDE they must have C
1. Recognize triples 1:ABC 2:ABC 3:ABC in addition to pairs of constraints 1:AB 2:AB
1. Recognize constraints 1:AB 2:AC 3:BC

Other:
1. Have the app suggest what guess I should make, and/or suggest what room I should go to
1. Record which color play piece each player is using
1. Assuming all players ask intelligent questions, consider making use of the information implied by their guesses - for instance, if a player is asking for ABC and is known to hold AB, they obviously do not have C
1. Support more editions of the game, and a selection screen
