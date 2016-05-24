########## Begin - Rewrite rules to block out some common exploits
#          against joomla's
#                             
# Block out any script trying to set a mosConfig value through the URL
RewriteCond %{QUERY_STRING} mosConfig_[a-zA-Z_]{1,21}(=|\%3D) [OR]

# Block out any script trying to base64_encode crap to send via URL
RewriteCond %{QUERY_STRING} base64_encode.*\(.*\) [OR]

# Block out any script that includes a <script> tag in URL
RewriteCond %{QUERY_STRING} (\<|%3C).*script.*(\>|%3E) [NC,OR]

# Block out any script trying to set a PHP GLOBALS variable via URL
RewriteCond %{QUERY_STRING} GLOBALS(=|\[|\%[0-9A-Z]{0,2}) [OR]

# Block out any script trying to modify a _REQUEST variable via URL
RewriteCond %{QUERY_STRING} _REQUEST(=|\[|\%[0-9A-Z]{0,2}) [OR]

# Block out any script that tries to set CONFIG_EXT (com_extcal2 issue)
RewriteCond %{QUERY_STRING} CONFIG_EXT(\[|\%20|\%5B).*= [NC,OR]

# Block out any script that tries to set sbp or sb_authorname via URL (simpleboard) 
RewriteCond %{QUERY_STRING} sbp(=|\%20|\%3D) [OR]
RewriteCond %{QUERY_STRING} sb_authorname(=|\%20|\%3D)

# Send all blocked request to homepage with 403 Forbidden error!
RewriteRule ^(.*)$ index.php [F,L]
#
########## End - Rewrite rules to block out some common exploits

