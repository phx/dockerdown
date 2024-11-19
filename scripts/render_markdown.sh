#!/bin/bash

# Retrieve the requested stylesheet from the query string, default to github.css if none specified
STYLE=$(echo "$QUERY_STRING" | grep -oP '(?<=style=)[^&]+' || echo "github")

# Ensure the style is valid, otherwise default to github
if [ ! -f "/usr/local/nginx/html/css/$STYLE.css" ]; then
    STYLE="github"
fi

# Start the HTML output
echo "Content-type: text/html"
echo ""

# Create a temporary file for the Lua filter
FILTER_FILE=$(mktemp)
cat > "$FILTER_FILE" << 'EOF'
function CodeBlock(block)
    if block.classes[1] == "mermaid" then
        return pandoc.RawBlock("html", "<pre class=\"mermaid\">" .. block.text .. "</pre>")
    end
    return block
end
EOF

# Convert the Markdown file to HTML
{
    echo "<html><head>"
    echo "<meta charset='utf-8'>"
    echo "<link rel='stylesheet' href='/css/$STYLE.css'>"
    echo "<script src='https://cdnjs.cloudflare.com/ajax/libs/mermaid/9.3.0/mermaid.min.js'></script>"
    echo "<script>
        document.addEventListener('DOMContentLoaded', function() {
            mermaid.initialize({
                startOnLoad: true,
                theme: '$STYLE' === 'github' ? 'default' : 'dark',
                securityLevel: 'loose',
                flowchart: {
                    htmlLabels: true,
                    curve: 'basis'
                }
            });
        });
    </script>
    <style>
        .mermaid {
            background: transparent !important;
            margin: 20px 0;
        }
        .error {
            color: red;
            background: #ffebee;
            padding: 10px;
            border-radius: 4px;
            margin: 10px 0;
        }
    </style>"
    echo "</head><body>"
    
    # Theme selector
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
    
    echo "<div style='margin-top: 50px;'>"
    
    # Process the markdown file
    pandoc "$PATH_INFO" \
        -f markdown \
        -t html \
        --no-highlight \
        --wrap=none \
        --lua-filter="$FILTER_FILE" \
        --metadata title="Documentation" \
        | sed 's/<pre><code class="language-mermaid">\(.*\)<\/code><\/pre>/<pre class="mermaid">\1<\/pre>/g'
    
    echo "</div></body></html>"
} | sed 's/--&gt;/-->/g; s/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g; s/&quot;/"/g'

# Clean up
rm -f "$FILTER_FILE"
