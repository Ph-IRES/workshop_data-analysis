# Cloning the Workshop Repo

For this to work, make sure that you've successfully completed the other setup steps. 

For MacOS computers, you can open your terminal and skip down to "Finally, Cloning the Repo".  For WinOS computers, we have to help you navigate to the WinOS directory system from the UbuntuOS virtual machine directory system.

---

## Navigating to the WinOS Directory System (WinOS Only)

1. Open your Ubuntu terminal. 
2. Use the `cd` bash command (cd = change directory) to move to your Windows directory as follows

  ```bash
  cd /mnt/c/Users/YOUR_WinOS_USERNAME/Downloads
  ```
  
  bash is a computer language used to control Linux computers. Ubuntu is a Linux OS.  MacOS is built on UNIX, and Linux is a clone of UNIX, so bash works on MacOS also.
  
---

## Finally, Cloning the Repo

Us the following bash command in your terminal to clone the workshop repo.  Consult steps 4 and 5 of the SSH Security Key instructions.

  ```bash
  # replace URL_TO_REPO with the URL you copy from the repo's webpage.  There is a green "Code" button that you select, then select "SSH", then copy the URL.
  git clone URL_TO_REPO
  ```
  
Note: in bash, the `#` denotes a human comment.  Lines that begin with `#` will not be executed.

