<?php
$fwtitle="WishList";
include("header.php");
print ("<!-- start wishlist.php -->\n");

function wish_show() {
	global $fwgray, $fwblack, $fwstrwishlist, $fwstrwprog, $fwstrwnick, $fwstrwtime, $fwstrwcomment, $fwstrwnosuch, $fwstrwask;
	include("/etc/todo.conf");
	mysql_connect(DBHOST, DBUSER, DBPASS);
	mysql_select_db("frugalware");
	$res1 = mysql_query("select * from wishlist");

	fwopenbox("$fwstrwishlist", 100, false, $fwgray);

	print "<table width=\"100%\" border=\"0\" cellspacing=1 cellpadding=1 bgcolor=\"$fwblack\">\n";
	print "<tr><td bgcolor=\"$fwgray\">$fwstrwprog</td><td bgcolor=\"$fwgray\">$fwstrwnick</td><td bgcolor=\"$fwgray\">$fwstrwtime</td><td bgcolor=\"$fwgray\">$fwstrwcomment</td></tr>\n";
	if (mysql_num_rows($res1) > 0) {
		while($sor = mysql_fetch_object($res1)) {
			print  "<tr><td bgcolor=\"$fwgray\">".$sor->wprog."</td><td bgcolor=\"$fwgray\">".$sor->wkero."</td><td bgcolor=\"$fwgray\">".$sor->wido."</td><td bgcolor=\"$fwgray\">".$sor->wcomment."</td></tr>";
		}
	}
	else {
		print "<tr><td colspan=4  bgcolor=\"$fwgray\">$fwstrwnosuch</td></tr>\n";
	}
	print "</table>\n";
	fwclosebox(false);

	print "<p align=center><a href=\"wishlist.php?op=ask\">$fwstrwask</a></p>\n";

}

function wish_ask() {

	global $fwgray, $fwblack, $fwstrwishlist, $fwstrwprog, $fwstrwnick, $fwstrwtime, $fwstrwcomment, $fwstrwnosuch, $fwstrwask, $fwstrinpgo, $fwstrinpdel;
	print "<table width=\"70%\" border=\"0\" cellspacing=1 cellpadding=1 align=center>\n";
	print "<tr><td colspan=2>$fwstrwask</td></tr>\n";
	print "<form method=\"POST\" action=\"wishlist.php?op=add\">\n";
	print "<tr><td>$fwstrwprog:</td><td><input type=text size=21 maxlength=20 name=wprog></td></tr>\n";
	print "<tr><td>$fwstrwnick:</td><td><input type=text size=31 maxlength=30 name=wnick></td></tr>\n";
	print "<tr><td valign=\"top\">$fwstrwcomment:</td><td><textarea name=\"wcomment\" cols=\"60\" rows=\"10\"></textarea></td></tr>\n";
	print "<tr><td align=right><input type=submit value=\"$fwstrinpgo\"></td><td align=left><input type=reset value=\"$fwstrinpdel\"></td></tr>\n";
	print "</form>\n";
	print "</table>\n";

}

function wish_add() {

	$wprog = $_POST["wprog"];
	$wnick = $_POST["wnick"];
	$wcomment = $_POST["wcomment"];

	global $fwstrerrnoprog, $fwstrerrnonick, $fwstrgotoshow;
	$stop = "";
	if ($wprog == "") {
		$stop = "<p align=center>$fwstrerrnoprog</p>\n";
	}
	else {
		if ($wnick == "") {
			$stop = "<p align=center>$fwstrerrnonick</p>\n";
		}
	}

	if ($stop == "") {
		if ($wcomment != "") {
			$temp = str_replace("\n", "<br>", $wcomment);
			$wcomment = str_replace(chr(13), "", $temp);
		}
		include("/etc/todo.conf");
	        mysql_connect(DBHOST, DBUSER, DBPASS);
		mysql_select_db("frugalware");
		$ret2 = mysql_query("insert into wishlist (wprog, wkero, wcomment, wido) values ('$wprog', '$wnick', '$wcomment', now())");
		if (!$ret2) {
			echo "1. ".mysql_errno(). ": ".mysql_error(). "<br>";
			exit();
		}
		print "<p align=center><a href=\"wishlist.php?op=show\">$fwstrgotoshow</a></p>\n";
	}
	else {
		print $stop;
	}

}

if ($_GET["op"] != "") {

	switch($_GET["op"]) {

		case "ask":
			wish_ask();
			break;
		
		case "add":
			wish_add();
			break;

		default;
			wish_show();
			break;

	}

}
else {

	wish_show();

}

print ("<!-- end wishlist.php -->\n");
include("footer.php");

?>
