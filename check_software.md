# Confirm that You Have the Software Installed

1.  Open your `terminal`
2.  Display `git` version, should be greater than or equal to that below

    ```bash
    git --version
    ```

4.  Open your `text editor`
5.  Open `RStudio`, version should be equal to or greater than that below

    ```r
    R version 4.4.1 (2024-06-14 ucrt) -- "Race for Your Life"
    Copyright (C) 2024 The R Foundation for Statistical Computing
    Platform: x86_64-w64-mingw32/x64
    ```

6.  Load `tidyverse` in `RStudio`

    ```r
    > library(tidyverse)
    ── Attaching core tidyverse packages ──── tidyverse 2.0.0 ──
    ✔ dplyr     1.1.4     ✔ readr     2.1.5
    ✔ forcats   1.0.0     ✔ stringr   1.5.1
    ✔ ggplot2   3.5.1     ✔ tibble    3.2.1
    ✔ lubridate 1.9.3     ✔ tidyr     1.3.1
    ✔ purrr     1.0.2     
    ── Conflicts ────────────────────── tidyverse_conflicts() ──
    ✖ dplyr::filter() masks stats::filter()
    ✖ dplyr::lag()    masks stats::lag()
    ℹ Use the conflicted package to force all conflicts to become errors
    ```

    If you don't have tidyverse then

    ```r
    install.packages("tidyverse")
    ```
