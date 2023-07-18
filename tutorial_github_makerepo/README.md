# Tutorial: Make GitHub Repo from Template

This tutorial is for the Ph-IRES program participants.

GitHub provides a platform for version control and collaboration that can enhance the management, sharing, and reproducibility of your research, including both data and R scripts. Here are a few reasons why you should consider using GitHub for your biology work:

    Version Control: GitHub provides a record of all changes made to a file or set of files over time, allowing you to track your progress and revert to a previous version if necessary. This is particularly helpful when working with complex scripts or large datasets, as it can prevent data loss and facilitate troubleshooting.

    Collaboration: GitHub can also make collaboration easier by allowing multiple people to work on the same project simultaneously. This is useful if you're part of a research team or collaborating with other scientists. Everyone can make their own changes and then merge them together, with GitHub keeping track of who made what changes.

    Reproducibility: One of the key issues in scientific research is reproducibility. By using GitHub, you can ensure that your scripts and data are available for others to validate your results or build upon your work. This openness is not only good scientific practice, but it can also enhance your reputation within the scientific community.

    Documentation: GitHub allows for thorough documentation of your project, which can be particularly helpful when returning to a project after some time has passed. This is also beneficial for others looking at your project, as it provides context and helps them understand your workflow and the choices you've made.

    Showcase Work: GitHub also serves as a portfolio of your work, and can be a great way to showcase your skills and projects to potential employers or collaborators.

    Integration with other tools: GitHub works well with many other tools used in data science and bioinformatics. For example, if you're using R, you can take advantage of RStudio's built-in tools for version control with Git.

Remember that while GitHub can be very useful, it also requires learning some new skills, particularly around the Git command line interface. If you're new to version control or Git, it may take some time to get up to speed. But the long-term benefits to your research and data management practices can be substantial.

---

## 1. Goto the [Ph-IRES Organization on GitHub](https://github.com/Ph-IRES)

![](phires_org.png)
	
---

## 2. Click on the green `New` button

![](new_button.png)

---

## 3. Select the template repo shown below

![](template_repo.png)
	
---

## 4. Name your repo according the provided naming convention.  You can also look at other repos for examples.

![](name_repo.png)
	
---

## 5. Make sure repo is private and select the green `Create repository` button

---

## 6. Clone the repo to your computer

* Using your terminal (could be either the stand alone app or in RStudio) navigate to the directory you want to download you repo to.

```
# mac
cd ~

# win
cd Downloads
```

---

## 7. Navigate to your repo on GitHub ([Ph-IRES Organization on GitHub](https://github.com/Ph-IRES)) and copy the SSH link from the green `Code` button

![](code_button.png)

---

## 8. Back in your terminal clone your Repo

```
git clone PasteLinkHere
```

## 9. Copy one of your data files into the data directory of your repo on your computer

Mac users can use the mac finder and win users can use the win explorer.  If you know how, you could also use the terminal to accomplish this.

## 10. Log you changes to the repo in the terminal

```
# goto your repo directory

cd NameOfYourRepo

# stage changes to your repo on your computer

git add --all

# commit those changes to your repo on your computer

git commit -m "added my first data file"

# push the changes to GitHub

git push
```

---

## 11. On GitHub, confirm that the data file was added

---

# 12. On GitHub, modify your README.md file in the main repo directory

---

# 13.  Pull the changes you made to your repo on GitHub to the copy of your repo on your computer in the terminal.

```
git pull
```

---

# 14. Confirm changes made on GitHub are now on you computer
