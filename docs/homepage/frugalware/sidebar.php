<?php
fwopenbox("$fwstrbrick", 100, false);
print("<div align=\"center\">
<A HREF=\"http://www.linuxlinks.com\"><IMG SRC=\"http://www.linuxlinks.com/portal/content/logos/newlogo5.gif\" BORDER=0 width=\"86\" height=\"24\" alt=\"Linux Links\"></A>
</div>\n");
print("<div align=\"center\">
<A HREF=\"http://www.distrotalk.net/\"><IMG SRC=\"http://www.distrotalk.net/images/dtbanner-small.png\" BORDER=0 width=\"86\" height=\"24\" alt=\"DistroTalk\"></A>
</div>\n");
if ($_SERVER['PHP_SELF'] == "/download.php" and $lang=="hu")
	print("<div align=\"center\"><br>
	<A HREF=\"http://www.linuxmedia.hu/?ref=frugalware\"><IMG SRC=\"/images/linuxmedia.jpg\" BORDER=0 width=\"120\" height=\"240\" alt=\"Linuxmedia.hu\"></A>
	</div>\n");
fwclosebox(false);
?>
