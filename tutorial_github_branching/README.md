# Branching a GitHub Repository

Branching is a powerful feature in Git that allows you to create independent lines of development in your repository.

---

## 1.	Branch: You start by creating a new branch in the repository.

Branching is like having multiple versions of your project where you can try out new ideas without affecting the `main` version.

Imagine your project is a tree. The main part of your project is the trunk, called the main branch. When you want to add new features or make changes without disturbing the main project, you can create a branch. This branch is like a new limb growing from the trunk where you can work independently.

Branching creates a new line of development within the same repository. Branches are part of the original repository and are used to work on different features or versions of the project in parallel. It's a way to isolate development without affecting the main or other branches, typically used for developing features, fixing bugs, or experimenting.

The default branch name in Git is `main`. Think of the `main` branch as the definitive branch where the source code of HEAD always reflects a production-ready state.

![](branch_new.png)

a) Navigate to the Repository: Go to the main page of the repository on GitHub.

b) Find the Branch Menu: At the top of the repository page, locate the branch menu, typically found near the top-left corner.

c) Create a New Branch: In the branch menu, type the name of your new branch. Choose a name that reflects the purpose of the branch (like feature-x or bugfix-y).

d) Create Branch: Press "Enter" or click the "Create branch" option from the drop-down menu.

## 2. Clone the branch to your computer

a) Open your terminal or command prompt.

b) Run the following command:
	
```bash
git clone -b [branch-name] [repository-url]
```
		
   Replace [branch-name] with the name of the branch you want to clone, and [repository-url] with the URL of the GitHub repository.

## 3.	Make Changes: Next, you make changes in your branch. This could be adding, deleting, or modifying files.
Once you've created the branch, you can start making changes in this isolated environment without affecting the main branch or other branches in the repository.

## 4.	Submit Pull Request: Once your changes are ready, you submit a pull request (PR) to the original repository. This is essentially a request to review and merge your changes.

a) Push Your Changes: First, make sure your changes are committed and pushed to your branch on GitHub.

 b) Navigate to the Repository: Go to the original repository from which you created your branch or fork.

 c) Start a New Pull Request: Click on the "Pull requests" tab, then click the "New pull request" button.

 d) Select Branches: Choose the base branch (the one you want your changes to be merged into) and compare branch (the one with your changes).

 e) Create Pull Request: Click "Create pull request". Give your pull request a title and description, explaining your changes.

 f) Submit for Review: After reviewing your changes and ensuring everything is correct, click "Create pull request".

## 5.	Review: The maintainers of the original repository (me) will then review your changes. They might suggest or request modifications.

## 6.	Discussion: There can be a discussion between you, the contributor, and the maintainers about the proposed changes.

## 7.	Approval and Merge: If the maintainers approve the changes, they can merge your pull request into the main branch of the repository, incorporating your changes into the codebase.

