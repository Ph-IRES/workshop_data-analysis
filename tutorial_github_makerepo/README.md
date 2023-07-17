# Tutorial: Make GitHub Repo from Template

This tutorial is for the Ph-IRES program participants.

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

git add

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