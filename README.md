# Data Analysis Workshop 2022

---

## Tentative Schedule

10 am - 6 pm Eastern

| Day | Date | Topic |
| --- | --- | --- |
| Tuesday | July 19 | Intro To R & Tidyverse |
| Wednesday | July 20 | Biodiversity & Life History Analysis |
| Thursday | July 21 | Life History & Geomorphometric Analysis |
| Friday | July 22 | Barcoding Analysis |
| Monday | July 25 | Microsatellite Analysis |

---

## Data Preparation


For those working on projects with individuals (Karen, Jerome, Noelle, Ingrid), you should prepare at least one (meta)data file. The file should follow tidy data principles (Wickham 2014). Briefly, each row should represent one individual and each column should have information about that individual.  Additionally, each column should only contain one type of data.  Each sheet in an excel workbook should only contain 1 table of tidy data.  If you have multiple tables of data, they should separated into different sheets in an excel workbook.  For Mikaela and Rebecca, your metadata files will have one video/site/transect per row. You will have additional data on the organisms observed at your sites.  Follow the format specified by your mentor.

For those with DNA data, your DNA will be turned into data by the Genomics Core Lab at TAMUCC and delivered to you.  

To share your data, and track your analysis, we are going to utilize github.  Please send me your github user id ASAP.  If you don’t have a github account, please create one (mentors too).  Git is a version control software and github is a cloudstorage server that serves as the hub of collaborative projects like yours and it is where the master copy of your data and data analysis scripts lie. https://www.freecodecamp.org/news/git-and-github-for-beginners/ .  

---

## Data Science Philosophy

Github makes following core data science philosophy easy.  The philosophy is, after data is digitized, all manipulations of the data should be documented and executed in code. This facilitates transparency, reproduction of methods, and we are progressing toward a day when you’re scientific research papers will be rejected if you don’t provide the scripts used to process your data.

---

## Software Requirements (Install Prior to Workshop)

To operate git on your computers there are several options, but Dave and I have our preferences.  If you have a mac, you’re good to go.  If you have a PC, you need to be sure to install Ubunutu on the windows linux subsystem.  I suggest you take full advantage of your access to Roy Roberts, and ask him to help you with this if he hasn’t already. https://ubuntu.com/tutorials/install-ubuntu-on-wsl2-on-windows-10#1-overview

We will employ R, and specifically the tidyverse package, to wrangle your data into submission. I know some of you may have had negative experiences with R, as I did when I was a student. But now, I’m a convert. I like to think I’m good at teaching it and it’s really going to make your life as a scientist easier if you learn it.  Please install R on your computers if you don’t have it, or if you haven’t installed it in the last month (MAC,   PC). R is open source and is updated frequently.  We can avoid problems if our R versions are all up to date.  
To make R more convenient to use, we will employ R Studio.  Please install R Studio on your computers if you don’t have it or if you haven’t installed it in the past month.   Go here https://www.rstudio.com/products/rstudio/download/ and select R Studio Desktop FREE.
