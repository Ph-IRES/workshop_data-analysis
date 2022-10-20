rm(list=ls())

#### Arithmetic ####
17 + 3
17 - 3
17 * 3
17 / 3
17 %% 3
17 %/% 3

##### Equalities ####
17 == 3
17 != 3
17 >= 3
17 <= 3
17 > 3 | 17 < 3
17 > 3 & 17 < 3

##### Variables ####
x <- -1.2345
y <- "Hi"
z <- 6.34 * 10^5
x
y
z

##### Data Types ####
x <- as.integer(50)
class(x)
1+x
z <- as.numeric(x^2)
y <- as.character("Bye")
q <- as.complex(1+3i)
r <- 3==4
is.numeric(x)
is.numeric(y)
is.numeric(z)
is.numeric(q)
is.numeric(r)
is.logical(r)

#### Math Functions ####
rm(list=ls())
x <- -1.234
abs_x <- abs(x)
sqrt_abs_x <- sqrt(abs_x)
ceiling(x); ceiling(abs_x)
floor(x); floor(abs_x)
trunc(x); trunc(abs_x)
(y <- round(x, 2))
(cos_y <- cos(y))
(z <- log(abs(y)))
(exp_z <- exp(z))

#### Vectors ####
rm(list=ls())
1:6
x <- c(1:6)
y <- c("a", "B", "c", "D")
y[3]
z <- seq(1, 40, 4)
z
z[3:6]
z[c(2,8,10)]

#### Statistical functions for vectors ####
length(y)
min(x); max(x)
sum(x); prod(x)
median(z)
mean(z)
var(z)
sd(z)
IQR(z)
summary(z)