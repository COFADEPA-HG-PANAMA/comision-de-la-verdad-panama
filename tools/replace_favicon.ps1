$root = 'C:\Users\RUSSO\Documents\website\TESTWEB'
Get-ChildItem -Path $root -Include *.htm,*.html -Recurse | ForEach-Object {
        $f = $_.FullName
        if (!(Test-Path "$f.bak")) { Copy-Item $f "$f.bak" -Force }
    $text = Get-Content $f -Raw -ErrorAction Stop
    $pattern = '(?is)(?:\s*<link[^>]*(?:icon|favicon|apple-touch)[^>]*>)+'
    $replacement = [Environment]::NewLine + '<link rel="icon" href="/favicon.ico" type="image/x-icon">' + [Environment]::NewLine
    $new = [regex]::Replace($text, $pattern, $replacement)
    if ($new -ne $text) {
        Set-Content -Path $f -Value $new -Encoding UTF8
        Write-Output "Updated: $f"
    }
}
