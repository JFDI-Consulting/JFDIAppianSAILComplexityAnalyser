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
$REif = "(if\()|(<xsl:if)";
$REand = "and\(";
$REor = "or\(";
$REchoose = "choose\(";
$REforEach = "(SYSTEM_SYSRULES_forEach)|(<xsl:for-each)";
$REqueries = "SYSTEM_SYSRULES_query";
$REbuiltIns = "SYSTEM_SYSRULES_(?!(forEac|quer|dd_))\w+";
$REruleBang = "#`".*`"\(";
$REdecisions = '#"SYSTEM_SYSRULES_dd_dri"';
$RElocals = "(^\s+local!.*\:)|(<xsl:value-of select)";
$REcomments = "/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+/";
$REcommentedOutCode = '(/\*.*((a!\w+\()|([\w\d]+:\s*")).*\*/)|(^/\*\s*[\w\d]+(([!(:]\s*(?!.*[\w\d]+\s+[\w\d]+))|null))|(^/\*\s*["&,)}{*])|(,\*/)|(/\*\s*(null|true|false|pagingInfo)\s*\*/)';
$REnotcode = "\*\*";
$REcommentGENID = '/\*\d+E-GEN\*/';

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
	
	$documentType = "";
	if($type -eq "Document") {
		$documentFilename = $xml.$haulNode.file;
		$documentFolder = $xml.$haulNode.$codeNode.uuid;
		$documentType = $documentFilename.Split('.')[-1];
		if($documentType -in "xsl", "xml", "html") {
			$code = Get-Content -Raw "content\$documentFolder\$documentFilename";
		}
	}
	

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
	$nodes = 0;
	
	$allComments = ([Regex]::Matches($code, $REcomments, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase+[System.Text.RegularExpressions.RegexOptions]::Multiline) | % {$_ -split "`n"} | ? {$_ -notmatch $REcommentGENID});
	$allCommentedOutCode = $allComments | ? { [Regex]::Matches($_, $REcommentedOutCode, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase+[System.Text.RegularExpressions.RegexOptions]::Multiline).Count -gt 0 -and -not [Regex]::Matches($_, $REnotcode).Count -gt 0};
	$justComments = $allComments | ? { [Regex]::Matches($_, $REcommentedOutCode, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase+[System.Text.RegularExpressions.RegexOptions]::Multiline).Count -eq 0 -or [Regex]::Matches($_, $REnotcode).Count -gt 0};
	$commentedOutCode = $allCommentedOutCode.Count;
	$comments = $justComments.Count;
	
	$testCases = $xml.$haulNode.typedValue.value.el.Count;
	$testCasesAssertions = $xml.$haulNode.typedValue.value.el.assertions.resultAssertions.Count;
	$testCasesExpectedOutput = $xml.$haulNode.typedValue.value.el.assertions.expectedOutput.Count - $testCasesAssertions;
	$testCasesNoAssertions = $xml.$haulNode.typedValue.value.el.assertions.Count - $testCasesExpectedOutput - $testCasesAssertions;

	$complexityScore = 1 + $ifs + $ands + $ors + $chooses + $forEachs + $querys + $builtIns + $ruleBangs + $decisions + $locals + $nodes;
	
	$cyclomaticComplexity = 1 + $ifs + $ands + $ors + $chooses + $forEachs;
	$architecturalComplexity = $querys + $ruleBangs + $nodes;
	$uiComplexity = $builtIns;
	
	$hasDescription = $description.Length -gt 0;
	
	$lineCount = ($code -split "`n").Length - $comments - $commentedOutCode;
		
	$commentsText = $justComments -join "`n";
	$commentedOutText = $allCommentedOutCode -join "`n";
	
	$data += [PSCustomObject]@{"File" = $file.Name; "Name" = $name; "Type" = $type; "IFs" = $ifs; "ANDs" = $ands; "ORs" = $ors; "CHOOSEs" = $chooses; "FOREACHs" = $forEachs; "QUERYs" = $querys; "BUILTINs" = $builtIns; "RULEBANGs" = $ruleBangs; "DECISIONs" = $decisions; "NODEs" = $nodes; "COMMENTs" = $comments; "COMMENTEDOUTs" = $commentedOutCode; "LOCALs" = $locals; "LOC"=$lineCount; "TESTCASEs"=$testCases; "TESTCASESNOASSERTIONs"=$testCasesNoAssertions; "TESTCASESEXPECTEDOUTPUTs"=$testCasesExpectedOutput; "TESTCASESASSERTIONs"=$testCasesAssertions; "CYCLOMATICCOMPLEXITY" = $cyclomaticComplexity; "ARCHITECTURALCOMPLEXITY" = $architecturalComplexity; "UICOMPLEXITY" = $uiComplexity; "COMPLEXITYSCORE" = $complexityScore; "DocumentType"= $documentType; "HASDESCRIPTION" = $hasDescription; "DESCRIPTION" = $description; "JustComments" = $commentsText; "CommentedOutCode" = $commentedOutText; };

}

dir processModel\*.xml | % {
	$type = $null;
	$file = $_;
	$codeNode = "";
	$type = "ProcessModel";

	$xml = [xml] (Get-Content $file);
	$codes = $xml.processModelHaul.process_model_port.pm.nodes.node.ac.'form-map'.pair.'form-config'.form.uiExpressionForm.expression.'#cdata-section' | ? {$_ -notlike '*41707069616E-GEN-DEBUG*'};
	$codes2 = $xml.processModelHaul.process_model_port.pm.nodes.node.ac.'output-exprs'.el.'#cdata-section';
	$codes3 = $xml.processModelHaul.process_model_port.pm.nodes.node.ac.acps.acp.expr.'#cdata-section' | ? {$_ -ne ""};

	$code = ($codes + $codes2 + $codes3) -join "`n";

	$nodeNames = $xml.processModelHaul.process_model_port.pm.nodes.node.ac.name.'#cdata-section'| ? {$_ -ne ""};
	$nodeXors = ($nodeNames | ? {$_ -eq "XOR"}).Count;
	$nodeOrs = ($nodeNames | ? {$_ -eq "OR"}).Count;
	$nodeAnds = ($nodeNames | ? {$_ -eq "AND"}).Count;

	$ifs = 0;
	$ands = $nodeAnds;
	$ors = $nodeOrs;
	$chooses = $nodeXors;
	$forEachs = 0;
	$querys = 0;
	$builtIns = 0;
	$ruleBangs = 0;
	$decisions = 0;
	$locals = 0;
	$comments = 0;
	$commentedOutCode = 0;
	$lineCount = 0;
	$testCases = 0;
	$testCasesExpectedOutput = 0;
	$testCasesAssertions = 0;
	$testCasesNoAssertions = 0;
	
	$documentType = "";
	
	$ifs += [Regex]::Matches($code, $REif, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count;
	$ands += [Regex]::Matches($code, $REand, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count;
	$ors += [Regex]::Matches($code, $REor, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count;
	$chooses += [Regex]::Matches($code, $REchoose, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count;
	$forEachs += [Regex]::Matches($code, $REforEach, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count;
	$querys += [Regex]::Matches($code, $REqueries, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count;
	$builtIns += [Regex]::Matches($code, $REbuiltIns, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count;
	$ruleBangs += [Regex]::Matches($code, $REruleBang, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count;
	$decisions += [Regex]::Matches($code, $REdecisions, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count;
	$locals += [Regex]::Matches($code, $RElocals, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase+[System.Text.RegularExpressions.RegexOptions]::Multiline).Count;

	$lineCount = ($code -split "`n").Length;

	
	$nodes = $xml.processModelHaul.process_model_port.pm.nodes.node.Count;
	
	$swimLanes = $xml.processModelHaul.process_model_port.pm.lanes.lane.Count;
	$annotations = $xml.processModelHaul.process_model_port.pm.annotations.Count;
	
	$allComments = ([Regex]::Matches($code, $REcomments, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase+[System.Text.RegularExpressions.RegexOptions]::Multiline) | % {$_ -split "`n"} | ? {$_ -notmatch $REcommentGENID});
	$allCommentedOutCode = $allComments | ? { [Regex]::Matches($_, $REcommentedOutCode, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase+[System.Text.RegularExpressions.RegexOptions]::Multiline).Count -gt 0 };
	$justComments = $allComments | ? { [Regex]::Matches($_, $REcommentedOutCode, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase+[System.Text.RegularExpressions.RegexOptions]::Multiline).Count -eq 0 };
	$commentedOutCode = $allCommentedOutCode.Count;
	$comments = $justComments.Count + $swimLanes + $annotations;
	
	$complexityScore = $ifs + $ands + $ors + $chooses + $forEachs + $querys + $builtIns + $ruleBangs + $decisions + $locals + $nodes;
	$cyclomaticComplexity = 1 + $ifs + $ands + $ors + $chooses + $forEachs;
	$architecturalComplexity = $querys + $ruleBangs + $nodes;
	$uiComplexity = $builtIns;
	
	$name = $xml.processModelHaul.process_model_port.pm.meta.name.'string-map'.pair[0].value.'#cdata-section';
	if($null -eq $name) {
		$name = $xml.processModelHaul.process_model_port.pm.meta.name.'string-map'.pair.value.'#cdata-section';
	}
	
	$commentsText = $justComments -join "`n";
	$commentedOutText = $allCommentedOutCode -join "`n";
	$data += [PSCustomObject]@{"File" = $file.Name; "Name" = $name; "Type" = $type; "IFs" = $ifs; "ANDs" = $ands; "ORs" = $ors; "CHOOSEs" = $chooses; "FOREACHs" = $forEachs; "QUERYs" = $querys; "BUILTINs" = $builtIns; "RULEBANGs" = $ruleBangs; "DECISIONs" = $decisions; "NODEs" = $nodes;"COMMENTS" = $comments; "COMMENTEDOUTs" = $commentedOutCode; "LOCALs" = $locals; "LOC"=$lineCount; "TESTCASEs"=$testCases; "TESTCASESNOASSERTIONs"=$testCasesNoAssertions; "TESTCASESEXPECTEDOUTPUTs"=$testCasesExpectedOutput; "TESTCASESASSERTIONs"=$testCasesAssertions; "CYCLOMATICCOMPLEXITY" = $cyclomaticComplexity; "ARCHITECTURALCOMPLEXITY" = $architecturalComplexity; "UICOMPLEXITY" = $uiComplexity; "COMPLEXITYSCORE" = $complexityScore; "DocumentType"= $documentType; "HASDESCRIPTION" = $hasDescription; "DESCRIPTION" = $description; "JustComments" = $commentsText; "CommentedOutCode" = $commentedOutText; };
}
return $data;