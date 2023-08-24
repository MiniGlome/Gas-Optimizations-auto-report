![made-with-python](https://img.shields.io/badge/Made%20with-Python3-brightgreen)

<!-- LOGO -->
<br />
<p align="center">
    <img src="https://github.com/MiniGlome/Gas-Optimizations-auto-report/assets/54740007/87afafb6-8b48-4d00-ac76-1e2494e17d58" alt="Logo" width="80" height="80">


  <h3 align="center">Gas-Optimizations auto report</h3>

  <p align="center">
    Python3 script to automatically create a Gas-Optimizations report for smart-contract audits
    <br />
    </p>
</p>


## About The Project

Like a lot of people, I started my smart-contract auditor journey by reporting gas-optimizations on [Code4rena](https://code4rena.com/). Hence, I created this bot to automate the process and earn a few rewards easily. Now is time to open-source it, so you can use it in you audit competitions too (Code4rena, CodeHawks, Hats, Immunefi...).

This script works with advenced regular expressions to check the presence of common optimization issues. All the rules are in the `Issues.py` file where you can add your own rules too.

Note that some of the findings may be false positives (especially issue `G16`) so a bit of manuall review is required.

## Getting Started
To get started you need to have python3 installed. If it is not the case you can download it here : https://www.python.org/downloads/

### Installation
Make sure you've already git installed. Then you can run the following commands to get the scripts on your computer:
   ```sh
   git clone https://github.com/MiniGlome/Gas-Optimizations-auto-report
   cd Gas-Optimizations-auto-report
   ```
The script does not have any requirement, it only uses packages already installed with all versions of Python.
   
## How to use
1. Create a directory with all the solidity files you want to analyse. This directory can be a direct copy of the `/src` of the project with nested folders.<br>See `/Example` for example.
   
2. Run the script with the folder name as parameter

```sh
python3 Auto-Report.py <Directory-with-all-the-source-files>
```
Example:
```sh
python3 Auto-Report.py Example
```

1. The result will be in the `/output` directory. See [/output/Example_gas_report.md](output/Example_gas_report.md) for example


## Donation
If you want to support my work, you can send 2 or 3 Bitcoins 🙃 to this address: 
```
bc1q4nq8tjuezssy74d5amnrrq6ljvu7hd3l880m7l
```
![bitcoin_address](https://user-images.githubusercontent.com/54740007/169100171-1061c7a0-207e-459b-84de-2d6bb93b0f38.png)
