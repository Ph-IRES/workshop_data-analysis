# Software Requirements (Install Prior to Workshop)

---

To operate git on your computers there are several options, but Dave and I have our preferences.  If you have a mac, you’re good to go.  [If you have a PC, you need to be sure to install Ubunutu on the windows linux subsystem](https://ubuntu.com/tutorials/install-ubuntu-on-wsl2-on-windows-10#1-overview).  I suggest you take full advantage of your access to Roy Roberts, and ask him to help you with this if he hasn’t already. 

## Required Software for the Workshop

In order to run the SSL pipeline and follow along with the workshop exercises, you will need to make sure you have the following accounts set-up and programs installed on your local computer (if you intend on using one of the computers in the computer lab, you only need to complete step 1).

1. Create a free [GitHub account](https://github.com/). 
    * Once you have your account, set up [two-factor authentification](https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa).
    * You will also need a personal access token (PAT) to use GitHub on the HPC cluster. To set this up, follow [these instructions](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token). **MAKE SURE TO SAVE THIS TOKEN SOMEWHERE ON YOUR COMPUTER SO YOU CAN COPY-AND-PASTE!**
2. **WINDOWS ONLY:** Install a Linux Distribution on Windows using the Windows Subsystem for Linux. Follow these steps:
    * Update Windows to the newest version (Windows 10 version 2004 and higher are required, you do not need Windows 11). To update, type "Check for Updates" in the taskbar search bar.
    * Open "Windows PowerShell". You can search for it in the same location where you typed "Check for Updates". Open Windows PowerShell by right-clicking and then left-clicking "Run as Administrator".
    * In the PowerShell Terminal, run the following command (do NOT copy and paste): `wsl --install`.
    * After the command finishes, restart your computer. Once it has restarted, an Ubuntu terminal will open and finish the installation. The installation will take a bit.
    * The terminal will ask for a Username and a Password. Use whatever Username you would like, it will become the name of the User directory. A password is not necessary if you do not want to use one, just enter nothing for both the "New Password" and "Retype Password" prompts.
    * After installation is complete, download [Windows Terminal](https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701?hl=en-us&amp%3Bgl=US).
    * Windows Terminal will open PowerShell automatically. Click the "v" symbol next to the "+" (new tab) button and go to "Settings".
    * The first option under "Startup" is "Default Profile". Change this to "Ubuntu" and save your changes.
    * To open again, just type "Terminal" in the taskbar search bar and open the App.
4. Install a text editor. Our recommended free editors:
    * For Macs: the free version of [BBEdit](https://www.barebones.com/products/bbedit/)
    * For Windows (PCs): [Notepad++](https://notepad-plus-plus.org/downloads/)
5. Install [R (v4.1.3)](https://cran.r-project.org/bin/windows/base/old/).
6. Install [RStudio](https://www.rstudio.com/products/rstudio/download/)
    * Once R and RStudio are installed, install the following packages (with all dependencies): tidyverse & adegenet.

---

We will employ R, and specifically the tidyverse package, to wrangle your data into submission. I know some of you may have had negative experiences with R, as I did when I was a student. But now, I’m a convert. I like to think I’m good at teaching it and it’s really going to make your life as a scientist easier if you learn it.  [Please install R](https://cloud.r-project.org/) on your computers if you don’t have it, or if you haven’t installed it in the last month (MAC, PC). R is open source and is updated frequently.  We can avoid problems if our R versions are all up to date.  

---

To make R more convenient to use, we will employ R Studio.  Please install R Studio on your computers if you don’t have it or if you haven’t installed it in the past month.   Go [here and select R Studio Desktop FREE](https://www.rstudio.com/products/rstudio/download/).

---

Install a text editor which is critial for viewing/editing DNA files or geomorphometric files.  The editors installed by your OS are inferior to our recommended free editors:
   * For Macs: the free version of [BBEdit](https://www.barebones.com/products/bbedit/)
   * For Windows (PCs): [Notepad++](https://notepad-plus-plus.org/downloads/)

---

[Install Geneious](https://www.geneious.com/download/). Be sure to download appropriately for your operating system.  Also, follow the “request a trial” link to get a 14 day trial license.  Please check your spam/junk folders, as this is where your trial license will usually end up.  *Don’t activate your license until next week.*  

---

[Install FigTree](http://tree.bio.ed.ac.uk/software/figtree/).  There are packages available for Mac, Windows, and Linux.


