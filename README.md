# PA2
Movie rating prediction software

The algorithm employed here is a multi-step algorithm. The steps are as follows:
1) Generate a list of users which have a similarity value to the target user (0-5), with 5 being least similar
-Find the intersection of the set of movies of the target and that of a given user, return 5 if not intersection
-Find the unweighted average of the difference using absolute value
-Sort list for all users
2) Make use of previous result to generate a rating prediction for the given user and movie by calculating a weighted mean 
-Find the weight for each user by using the formula 5/similarity, with lower similarity values generating a higher weight.
-Use formula for weighted average amongst all users to generate prediction

Time Analysis: 
The run_test(k) has k default to 150, through multiple code runs, I found this the most optimal running time. At this number the expected running time on my machine (which is of modest build) is around 15 seconds. The time complexity is of O(n^2). 
The running time for increasing the set by 100 gets 100x greater, so this algorithm poorly scales.

Results Analysis:
The standard deviation of error for the algorithm hovered around 1.0, with a mean error of .02 for a modest sample size. The mean error seems to converge towards 0 as k increases, implying that there is a slight trend towards more accurate guesses than less accurate guesses that is seen at higher test sets. 
