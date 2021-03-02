<#
.SYNOPSIS 
A complexity estimation script for Appian SAIL code.

.DESCRIPTION
This is not a cyclomatic complexity analysis tool. Instead it just counts various indicators of complexity and returns a array of those counts per file.

.NOTES
v1.0 - by Joel Jeffery, JDFI Consulting
MIT License

Copyright (c) 2021 JFDI Consulting

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

.FUNCTIONALITY
To use:

1) Export your project from Appian Designer as a zip file. 
2) Unzip the export file to a folder. 
3) Open PowerShell and change to that folder.
4) Run this script.

.LINK
https://github.com/JFDI-Consulting/JFDIAppianSAILComplexityAnalyser

.LINK
https://jfdi.info

.OUTPUTS
Returns an array of complexity metrics for each file in your Appian project with the following properties:

File, Name, Type, IFs, ANDs, ORs, CHOOSEs, FOREACHs, QUERYs, BUILTINs, RULEBANGs, DECISIONs, NODEs, LOCALs, LOC

.EXAMPLE
Calculate-AppianComplexityScores.ps1 | Export-CSV -NoTypeInformation report.csv;

.EXAMPLE
$data = Calculate-AppianComplexityScores.ps1;

#>
$REif = "if\(";
$REand = "and\(";
$REor = "or\(";
$REchoose = "choose\(";
$REforEach = "SYSTEM_SYSRULES_forEach";
$REqueries = "SYSTEM_SYSRULES_query";
$REbuiltIns = "SYSTEM_SYSRULES_(?!(forEach|query))";
$REruleBang = "#`".*`"\(";
$REdecisions = "SYSTEM_SYSRULES_dd_dr";
$RElocals = "^\s+local!.*\:";
$REcomments = "/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+/";
$REcommentedOutCode = "[\w\d]+[!(]";

$data = @();
dir content\*.xml | % {
	$type = $null;
	$file = $_;
	$codeNode = "";
	$haulNode = "contentHaul";
	if($null -ne ($file | Select-String "<rule>")) {
		$codeNode = "rule";
		if($file | Select-String "<preferredEditor>legacy</preferredEditor>") {
			$type = "Rule";
		} elseif($file | Select-String "<preferredEditor>interface</preferredEditor>") {
			$type = "Interface";
		}
	} elseif ($null -ne ($file | Select-String "<constant>")) {
		$codeNode = "constant";
		$type = "Constant";
	} elseif ($null -ne ($file | Select-String "<document>")) {
		$codeNode = "document";
		$type = "Document";
	} elseif ($null -ne ($file | Select-String "<folder>")) {
		$codeNode = "folder";
		$type = "Folder";
	} elseif ($null -ne ($file | Select-String "<rulesFolder>")) {
		$codeNode = "rulesFolder";
		$type = "RulesFolder";
	} elseif ($null -ne ($file | Select-String "<report>")) {
		$codeNode = "report";
		$type = "Report";
	} elseif ($null -ne ($file | Select-String "<communityKnowledgeCenter>")) {
		$codeNode = "communityKnowledgeCenter";
		$type = "CommunityKnowledgeCenter";
	} elseif ($null -ne ($file | Select-String "<decision>")) {
		$codeNode = "decision";
		$type = "Decision";
	} elseif ($null -ne ($file | Select-String "<outboundIntegration>")) {
		$codeNode = "outboundIntegration";
		$type = "OutboundIntegration";
	} 
	
	$xml = [xml] (Get-Content $file);
	
	$code = $xml.$haulNode.$codeNode.definition;
	$name = $xml.$haulNode.$codeNode.name;
	$description = $xml.$haulNode.$codeNode.description;

	$ifs = [Regex]::Matches($code, $REif, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count;
	$ands = [Regex]::Matches($code, $REand, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count;
	$ors = [Regex]::Matches($code, $REor, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count;
	$chooses = [Regex]::Matches($code, $REchoose, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count;
	$forEachs = [Regex]::Matches($code, $REforEach, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count;
	$querys = [Regex]::Matches($code, $REqueries, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count;
	$builtIns = [Regex]::Matches($code, $REbuiltIns, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count;
	$ruleBangs = [Regex]::Matches($code, $REruleBang, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count;
	$decisions = [Regex]::Matches($code, $REdecisions, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count;
	$locals = [Regex]::Matches($code, $RElocals, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase+[System.Text.RegularExpressions.RegexOptions]::Multiline).Count;
	
	$allComments = ([Regex]::Matches($code, $REcomments, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase+[System.Text.RegularExpressions.RegexOptions]::Multiline) | % {$_ -split "`n"});
	$allCommentedOutCode = $allComments | ? { [Regex]::Matches($_, $REcommentedOutCode, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase+[System.Text.RegularExpressions.RegexOptions]::Multiline).Count -gt 0 };
	$justComments = $allComments | ? { [Regex]::Matches($_, $REcommentedOutCode, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase+[System.Text.RegularExpressions.RegexOptions]::Multiline).Count -eq 0 };
	$commentedOutCode = $allCommentedOutCode.Count;
	$comments = $justComments.Count;
	
	
	$hasDescription = $description.Length -gt 0;
	
	$lineCount = ($code -split "`n").Length;
	
	$nodes = 0;
		
	$data += [PSCustomObject]@{"File" = $file.Name; "Name" = $name; "Type" = $type; "IFs" = $ifs; "ANDs" = $ands; "ORs" = $ors; "CHOOSEs" = $chooses; "FOREACHs" = $forEachs; "QUERYs" = $querys; "BUILTINs" = $builtIns; "RULEBANGs" = $ruleBangs; "DECISIONs" = $decisions; "NODEs" = $nodes; "COMMENTs" = $comments; "COMMENTEDOUTs" = $commentedOutCode; "LOCALs" = $locals; "LOC"=$lineCount; "HASDESCRIPTION" = $hasDescription; "DESCRIPTION" = $description; "JustComments" = $justComments; "CommentedOutCode" = $allCommentedOutCode;}

}

dir processModel\*.xml | % {
	$type = $null;
	$file = $_;
	$codeNode = "";
	$type = "ProcessModel";

	$xml = [xml] (Get-Content $file);

	$ifs = 0;
	$ands = 0;
	$ors = 0;
	$chooses = 0;
	$forEachs = 0;
	$querys = 0;
	$builtIns = 0;
	$ruleBangs = 0;
	$decisions = 0;
	$locals = 0;
	$comments = 0;
	$commentedOutCode = 0;
	$lineCount = 0;
	$nodes = $xml.processModelHaul.process_model_port.pm.nodes.node.Length;
	$justComments = @();
	$allCommentedOutCode = @();
	
	$name = $xml.processModelHaul.process_model_port.pm.meta.name.'string-map'.pair[0].value.'#cdata-section';
	if($null -eq $name) {
		$name = $xml.processModelHaul.process_model_port.pm.meta.name.'string-map'.pair.value.'#cdata-section';
	}
	$data += [PSCustomObject]@{"File" = $file.Name; "Name" = $name; "Type" = $type; "IFs" = $ifs; "ANDs" = $ands; "ORs" = $ors; "CHOOSEs" = $chooses; "FOREACHs" = $forEachs; "QUERYs" = $querys; "BUILTINs" = $builtIns; "RULEBANGs" = $ruleBangs; "DECISIONs" = $decisions; "NODEs" = $nodes;"COMMENTS" = $comments; "COMMENTEDOUTs" = $commentedOutCode; "LOCALs" = $locals; "LOC"=$lineCount; "JustComments" = $justComments; "CommentedOutCode" = $allCommentedOutCode;}
}
return $data;