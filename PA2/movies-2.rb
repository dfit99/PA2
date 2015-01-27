class MovieData

	def initialize (training_set, test_set = :NIL)
		@movieStore = Array.new
		@test_set = Array.new
		load_data(training_set, test_set)
	end

	#loads data into data structures 
	def load_data (training_set, test_set = :NIL)
                base = training_set + "/u.data" if test_set == :NIL
		base = training_set + "/" + test_set.to_s + ".base" if test_set != :NIL
		file = File.open (base)

		i=0
		file.each_line do |line|
			@movieStore[i] = line.split(/\s/)
			i += 1
		end
		if test_set != :NIL then
			test_set = training_set + "/" + test_set.to_s + ".test"
			file2 = File.open(test_set)
		        file2.each_line do |line|
			        @test_set << line.split(/\s/)
		        end
                else
                        @test_set = @movieStore
                end
              
		user_movie_index()
	end
	
	#iniatilizes an array of user<(movie,rating), ...) tuples, followed by an array of <movie,<user1..>> tuples and an array of <user,<movie1...>> tuples 
	def user_movie_index ()
		@user_rating_index= Hash.new{|hash, key| hash[key] = Hash.new(0)}
		@user_movie_index = Hash.new{|hash,key| hash[key] = Array.new}
		@movie_user_index = Hash.new{|hash,key| hash[key] = Array.new}
		@movieStore.each do |line|
			user_name = line[0]
			movie_name = line[1]
			movie_rating = line[2] 
			movie_rating_pairs = @user_rating_index[user_name]
			movie_rating_pairs[movie_name] = movie_rating
			@user_movie_index[user_name] << movie_name
			@movie_user_index[movie_name] << user_name
		end
	end

	#given a movie returns set of users
	def viewers(movie)
		return @movie_user_index[movie]	
	end
	
	#given a user, returns set of movies
	def movies(user)
		return @user_movie_index[user]
	end
	
	#given a user and movie, returns rating
	def rating(user,movie)
		movie_rating_index = @user_rating_index[user]
		movie_rating = movie_rating_index[movie]
		return movie_rating.to_f
	end 

	#returns a similarity ranking from 0-5 (0 most similar) between 2 users based on average difference
	def similarity (user1,  user2)
		
		user1_index = @user_rating_index[user1]
		user2_index = @user_rating_index[user2]
		total_diff = 0
		counter=0

		user1_index.each_key do |movie|
			if user2_index.has_key? (movie) 
				diff = (user1_index[movie].to_i - user2_index[movie].to_i).abs #abs value difference to be summed then divided by total
				total_diff += diff
				counter+=1
			end
		end
		if counter == 0
			return 5.0
		end
		return  (total_diff.to_f/counter) 
	end

        #returns a sorted list of similarity between user1 and everyone else, bases similarity on average difference, returns 0-5 (5 least similar)
	def most_similar (user1)
		similarity_list = Array.new
		@user_rating_index.each_key do |key|
			unless key == user1 
				pair = Array.new()
				pair = [similarity(user1, key), key]
				similarity_list <<  pair
			end 
		end
		similarity_list=  similarity_list.sort
		return similarity_list
	end

	#predicts how user1 will rate a movie
        def predict (user1, movie)
                list_of_users = most_similar(user1)
                counter=0.0
                weighted_sum=0.0
                list_of_users.each do |sim, user| #go through each user, sim = similarity level 
                        user_rating = rating(user,movie) 
                        next if (user_rating == 0 || sim.to_i==0)
                        weighted_sum = (5.0/sim.to_f) * user_rating + weighted_sum #take weighted average
                        counter = (5.0/sim.to_f) + counter
                 end
                begin
                num = (weighted_sum/counter).round
                return num
                rescue FloatDomainError
                end
        end

	#runs a test on a given amount of reviews, returns MovieTest object
        def run_test(k = 150)
                tests = Array.new
                i=0
	        @test_set.each do |line|
                        break if i==k
			true_rating = line[2]
			user_name = line[0]
			movie_name = line[1]
			guess_rating = predict(user_name, movie_name)
                        data = [user_name, movie_name, true_rating, guess_rating] #stores into tuple
                        tests << data
                        i+=1
                end
                mt = MovieTest.new(tests)
                return mt
                
       end
                
end

class MovieTest
	
	def initialize (data)
		@data = data
	end

	
	#returns standard  deviation by looping through and using typical formula
        def stddev 
                variance =0
                count = 0.0
                @data.each do |line|
                        true_rating = line[2]
                        guess_rating = line[3]
                        count =  count + 1
                        variance  = (true_rating.to_i - guess_rating.to_i)**2 + variance
                end

                @variance = variance/count
                @stddev = Math.sqrt(@variance)
                return @stddev.round(2)
        end

	#returns RMS, equivalent to standard deviation
        def rms
                return stddev
        end

	#returns means difference, similar to finding RMS but uses absolute value instead
        def mean 
                variance =0
                count = 0.0
                @data.each do |line|
                        true_rating = line[2]
                        guess_rating = line[3]
                        count =  count + 1
                        variance  = (true_rating.to_i - guess_rating.to_i).abs + variance
                end
                return (variance/count.to_f)
        end

	#returns array of tuples (user, movie, original rating, guess rating)
        def to_a 
                return @data
        end

end



#a = MovieData.new("ml-100k")
#print a.movies("1")
