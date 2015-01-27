# PA2
Movie rating prediction software

The algorithm employed here  is a multi-step algorithm. The steps are as follows:
1) Generate a list of users which have a similarity value to the target user (0-5), with 5 being least similar
-Find the intersection of the set of movies of the target and that of a given user, return 5 if not intersection
-Find the unweighted average of the difference using absolute value
-Sort list for all users
2) Make use of previous result to generate a rating prediction for the given user and movie by calculating a weighted mean 
-Find the weight for each user by using the formula 5/similarity, with lower similarity values generating a higher weight.
-Use formula for weighted average amongst all users to generate prediction

