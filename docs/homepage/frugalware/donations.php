<?
$fwtitle="Donations";
include("header.php");

fwopenbox($fwdonatestring, 80, false);
print $fwdonatewelcome;
fwclosebox(false);
print("<p>");

fwopenbox("The Frugalware Team", 80, false);
print("<div align=left>Wishes:<ul>
<li>American, <i>not</i> ISO-only mirror</li>
<li>10-20GB IDE HDD for testing Xen</li>
<li>10GB IDE HDD for testing the setup</li>
<li>PegasosPPC or/and other PowerPC computer to use as buildserver</li>
<li>2 pieces of IDE harddisks as big as can be - into x86_64 buildserver</li>
<li>a powerful i686 buildserver</li>
</ul>Received:<ul>
<li>Socket939 Motherboard + AMD Athlon64 3000+ CPU Socket939 version + 512MB DDR400 RAM (this will be our x86_64 buildserver)</li>
<li>Codegen case for the new x86_64 buildserver (Krisztian VASAS)</li>
<li>i586 Server: Pentium MMX 200 Mhz CPU, 64 Mb memory, 2.8Gb + 37Gb HDD (Botond Balazs, Miklos Vajna)</li>
<li>Main server hosting (Sandor Szentirmay)</li>
<li>Hungarian mirrors: inflame.hu, linuxforum.hu, FSN.hu</li>
<li>European mirrors: belnet.be</li>
<li>Asian mirror: Taipei City, Taiwan (National Taiwan University, cle.linux.org.tw)</li>
<li>i686 Server: Pentium III (Coppermine) 600 Mhz, 256 Mb memory (the developer team)</li>
<li>i686 build server: Pentium II (Deschutes) 300 Mhz, 384 Mb memory</li>
<li>i686 build server hosting</li>
<li>Advertising: linuxuser.hu, linuxlinks.com</li>
<li>2x40GB IDE HDD (Szalai, Ervin)</li>
<li>2x160GB IDE HDD for the i686 server (Miklos Vajna)</li>
<li>40GB IDE HDD (Kovacs, Janos)</li>
<li>Dell Optiplex P4 1.6GHz machine for main server</li>
</ul></div>");
fwclosebox(false);
print("<p>");

fwopenbox("Andras Voroskoi", 80, false);
print("<div align=left>Received:<ul>
<li>Ati video card for fglrx package testing (David Kimpe)</li>
</ul></div>");
fwclosebox(false);
print("<p>");

include("footer.php");
?>
