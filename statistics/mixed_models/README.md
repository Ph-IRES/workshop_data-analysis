# TESTING HYPOTHESES WITH MIXED MODELS

Under construction

---

## Getting Started

Open [`miexed_models.R`](mixed_models.R) in Rstudio and run the `INITIALIZATION` section

NOTE: after loading these packages, you may find that tidyverse commands are affected. The solution is to add the appropriate package name before commands that break code such as `dplyr::select` if `select` doesn't work correctly anymore. This happens when multiple packages have the same command names. The last package loaded takes precidence, and your tidyverse commands break. You could load tidyverse last, but invariably, you will load a package after tidyverse that breaks one of its commands, so it's impossible to avoid this.

We will use Ingrid's data set on sex change in _Halichores scapularis_. 

---

##