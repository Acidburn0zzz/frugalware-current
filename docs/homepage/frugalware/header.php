<?php

# let's see whether the visitor have already changed language
# if yes, a cookie is exists on the visitor's browser

if (isset($_COOKIE["fwcurrlang"])) {
	$lang=$_COOKIE["fwcurrlang"];
}

include("config.php");
include("lib.php");

// set $pagename variable
for ($i=0; $i<strlen($PHP_SELF); $i++)
{
	if (substr($PHP_SELF, $i, 1) == "/")
	{
		$uccsoper=$i;
	}
}
$pagename=substr($PHP_SELF, $uccsoper+1);
header("Content-type: text/html; charset=$fwcharset");
?>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<?php
// head section
print("<head>\n");
print("<title>$fwtitle - Frugalware Linux</title>\n");
print("<META NAME=\"AUTHOR\" CONTENT=\"Miklos Vajna, Krisztian VASAS\">\n");
print("<META NAME=\"COPYRIGHT\" CONTENT=\"Copyright (c)" .
	" 2000-" . date("Y") . " by Miklos Vajna\">\n");
// nice icon for browsers
print("<link REL=\"icon\" href=\"/images/favicon.ico\">\n");
print("<script type=\"text/javascript\" src=\"menu.js\">
/* AnyLink CSS Menu script- (c) Dynamic Drive DHTML code library (www.dynamicdrive.com)
 * This notice MUST stay intact for legal use
 * Visit Dynamic Drive at http://www.dynamicdrive.com/ for full source code */
</script>
<style type=\"text/css\">
	a { color: $fwlink; text-decoration: none; }
	a:link:hover { color: $fwlink; text-decoration: underline; }
	a:visited:hover { color: $fwlink; text-decoration: underline; }
	a:visited { color: $fwlink; text-decoration: none; }
	a.menu { color: $fwwhite; text-decoration: none; }
	a.menu:hover { color: $fwwhite; text-decoration: underline; }
	body { font-family: Arial, Helvetica, Verdana, Tahoma, monospace; font-size: 14px; background-color : ${fwgray}; }
	.menulinkcss{ position:absolute; visibility: hidden; border:1px solid $fwblack; background-color: $fwwhite; }
	.menulinkcss a{ display: block; padding-left: 5px; padding-right: 5px; }
	.screenshots div { float: left; width: 220px; height: 180px; }
	FIELDSET.fieldset LEGEND {
		font: bold 11px Verdana, Geneva, Arial, Helvetica, sans-serif;
		letter-spacing: .1em;
		color: rgb(0, 80, 154);
		padding: 0 0.5em;
		vertical-align: top;
	}
	FIELDSET.fieldset {
		border: 1px solid rgb(130, 150, 187);
		clear: left;
		margin: 14px 0 0 0;
		padding: 4px 8px 4px 8px;
		text-align: left;
	}
</style>\n");
print("</head>\n");

// body
print("<body>\n");

print ("<!-- start header.php -->\n");


fwopenbox("<table width=\"100%\">
  <tr>
    <td align=left>
      <big><b>Frugalware Linux</b></big><br>Let's make things frugal!
    </td>
    <td align=right width=\"60%\">
	<a href=\"http://www.google.com/\"><img src=\"images/google.gif\" border=\"0\" alt=\"Google\"></a>
    </td>
    <td>
      <form method=get action=\"http://www.google.com/custom\">
        <input type=text name=q size=15 maxlength=150 value=''>
        <input type=submit name=sa value=\"$fwstrsearch\">
        <input type=hidden name=domains value='$fwsitename'>
        <input type=hidden name=sitesearch value='$fwsitename'>
      </form>
    </td>
  </tr>
</table>", 100, true);

include ("menu.php");

fwclosebox(true);

print("<br>
<table width=\"100%\">
  <tr>
    <td valign=top width=\"15%\">
      <div align=\"center\">\n");

// left side box-list
include("logo.php");
print("<p>");
include("flag.php");
print("<p>");
include("serverinfo.php");
print("<p>");
include("sidebar.php");
// box-list ends

print("      </div>
    </td>
    <td valign=top width=\"70%\">
      <div align=\"center\">\n"); // real body starts

print ("<!-- end header.php -->\n");

?>
