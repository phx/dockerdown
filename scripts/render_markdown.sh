#!/bin/bash

# Retrieve the requested stylesheet from the query string, default to github.css if none specified
STYLE=$(echo "$QUERY_STRING" | grep -oP '(?<=style=)[^&]+' || echo "github")

# Ensure the style is valid, otherwise default to github
if [ ! -f "/usr/local/nginx/html/css/$STYLE.css" ]; then
    STYLE="github"
fi

# Start the HTML output with a dropdown menu for theme selection
echo "Content-type: text/html"
echo ""
echo "<html><head><link rel='stylesheet' href='/css/$STYLE.css'></head><body>"
echo "<div style='position: fixed; top: 10px; right: 10px;'>"
echo "<form method='GET'>"
echo "    <label for='style'>Select Theme:</label>"
echo "    <select name='style' onchange='this.form.submit()'>"
for cssfile in /usr/local/nginx/html/css/*.css; do
    cssname=$(basename "$cssfile" .css)
    if [ "$STYLE" = "$cssname" ]; then
        echo "        <option value='$cssname' selected>${cssname}</option>"
    else
        echo "        <option value='$cssname'>${cssname}</option>"
    fi
done
echo "    </select>"
echo "</form>"
echo "</div>"

# Convert the Markdown file to HTML using pandoc
echo "<div style='margin-top: 50px;'>"
pandoc "$PATH_INFO" -f markdown -t html
echo "</div></body></html>"
