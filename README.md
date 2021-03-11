# JFDI Appian SAIL Complexity Analyser
A complexity estimation script for Appian SAIL code written in PowerShell.

## Author
Joel Jeffery, JFDI Consulting Ltd

## Background
I looked plenty, but I couldn't find any tools to help analyse complexity of Appian applications. So, here's my effort.

## Before you start
Make sure all of your Expression Rules and Interfaces have been formatted in Appian Designer. Open each file, hit CTRL-SHIFT-F and save. 

Yes. I know that means you'll get many lines that only have one bracket on them. 

Yes, this kind of line count is a very blunt instrument.

Consistent formatting is really all we have to determine line count. It's not much, but at least it's something.

## Measures of complexity
In the absence of any tools for cyclomatic complexity analysis, I went for some indicators of complexity. Specifically, I wanted to count the numbers of:
- Ifs (branching logic)
- Ands
- Ors
- Chooses (switching logic)
- For Eaches (looping logic)
- Queries (data access)
- Calls to Expression Rules and Interfaces
- Calls to internal Appian functions and interface components
- Decision Tables
- Locals (and value-ofs for XSL files)
- Comments (and Annotations / Swimlanes in Process Models)
- Commented Out Code (!)
- Lines (in SAIL code - even in Process Models and XSL files)
- Process Nodes (in Process Models)
- Object Type / Document Type
- Test Cases (all/expected output/assertions/no assertion)

## Shortcomings
There are many. 😀

This script does not even try to calculate cyclomatic complexity. It's a rough guide to areas in code that are worth looking at closer. It's best used when comparing two or more projects to determine relative levels of complexity.

It should be noted that this tool is not a replacement for code reviews and good Appian development practices. It's best used to help find hotspots worthy of closer investigation.

The main objects code complexity data is extracted from are:
- Expression Rules
- Interfaces
- Process Models (including Gateways and SAIL Expressions)
- XSL Files

## Interpreting the results
It's up to you. For my use, I decided that some of these counters have more architectural weight than others. I generally make a spread sheet and sum specific columns together to derive various measures of complexity. Then sort by those columns descending.

A small line count, with a high proportion of Expression Rules and Interfaces suggests at good reusability or decomposition.

However, a large line count, with a low proportion of Expression Rules and Interfaces hints at low reuse and poor separation of concerns.

## Usage
1. Export your Appian application as a zip file
![Export Appian Application](https://user-images.githubusercontent.com/20968935/109966367-187c7a80-7ce8-11eb-887c-67d1a8ab2be2.png)

2. Extract the zip file to a folder
3. Open PowerShell and navigate to that folder (e.g. cd c:\Appian\MyProject)
4. Run the script

You can run the script in a couple of useful ways.

To create a CSV of the output, use in conjunction with Export-CSV:

```powershell
Calculate-AppianComplexityScores.ps1 | Export-CSV -NoTypeInformation report.csv;
```

To instead use the results within your own scripts, return the data into a variable:

```powershell
$data = Calculate-AppianComplexityScores.ps1;
```

You could open the CSV in Excel or output the variable directly to Out-GridView:
```powershell
$data | select * | Out-GridView;
```

![Example Output](https://user-images.githubusercontent.com/20968935/109705553-d2140800-7b8f-11eb-8d18-948058ffd653.png)

There is also a summary mode showing various metrics:
```powershell
Calculate-AppianComplexityScores.ps1 -Summary;
```

You can also specify a path...:
```powershell
Calculate-AppianComplexityScores.ps1 -Path "C:\Downloads\My App v1.0.0";
```

...or paths to multiple projects:
```powershell
Calculate-AppianComplexityScores.ps1 -Summary -Paths "My App v1.0.0","My App v1.0.1","My App v1.0.2";
```

