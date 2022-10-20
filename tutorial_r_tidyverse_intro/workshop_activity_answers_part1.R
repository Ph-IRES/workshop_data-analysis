#### 1 ####
#integer, logical, character, complex, numeric

#### 2 ####
#c(), seq(), rep()

#### 3 ####
my_vector <- seq(2, 100, 2)

#### 4 ####
(my_vector <- seq(2, 100, 2))
print(my_vector)
view(my_vector)
my_vector

#### 5 ####
my_vector_div_12 <- my_vector[my_vector %% 12 == 0]

#### 6 #### 
sum(my_vector_div_12)

#### 7 ####
my_vector[5] * my_vector[10] * my_vector[15]
prod(my_vector[c(5, 10, 15)])

