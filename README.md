# JFDI Appian SAIL Complexity Analyser
A complexity estimation script for Appian SAIL code

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
- Locals
- Lines (in SAIL code)
- Process Nodes (in Process Models)

## Shortcomings
There are many. 😀

This script does not even try to calculate cyclomatic complexity. It's a rough guide to areas in code that are worth looking at closer. It's best used when comparing two or more projects to determine relative levels of complexity.

It should be noted that this tool is not a replacement for code reviews and good Appian development practices. It's best used to help find hotspots worthy of closer investigation.

## Interpreting the results
It's up to you. For my use, I decided that some of these counters have more architectural weight than others. I generally make a spread sheet and sum specific columns together to derive various measures of complexity. Then sort by those columns descending.

A small line count, with a high proportion of Expression Rules and Interfaces suggests at good reusability or decomposition.

However, a large line count, with a low proportion of Expression Rules and Interfaces hints at low reuse and poor separation of concerns.

## Usage
1. Export your Appian application as a zip file.
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
