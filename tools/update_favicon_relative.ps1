$root = 'C:\Users\RUSSO\Documents\website\TESTWEB'
Get-ChildItem -Path $root -Include *.htm,*.html -Recurse | ForEach-Object {
    $f = $_.FullName
    if (!(Test-Path "$f.bak")) { Copy-Item $f "$f.bak" -Force }
    $dir = $_.DirectoryName
    # compute depth relative to root
    $relative = ''
    if ($dir -eq $root) {
        $relative = 'favicon.ico'
    } else {
        $sub = $dir.Substring($root.Length).TrimStart('\')
        if ($sub -eq '') { $levels = 0 } else { $levels = ($sub -split '\\').Length }
        if ($levels -eq 0) { $relative = 'favicon.ico' } else { $prefix = (1..$levels | ForEach-Object { '..' }) -join '/'; $relative = "$prefix/favicon.ico" }
    }
    $text = Get-Content $f -Raw -ErrorAction Stop
    $pattern = '(?is)(?:\s*<link[^>]*(?:icon|favicon|apple-touch)[^>]*>)+'
    $abs = '<link rel="icon" href="/favicon.ico" type="image/x-icon">'
    $rel = "<link rel='icon' href='$relative' type='image/x-icon'>"
    $replacement = [Environment]::NewLine + $abs + [Environment]::NewLine + $rel + [Environment]::NewLine
    $new = [regex]::Replace($text, $pattern, $replacement)
    if ($new -ne $text) {
        Set-Content -Path $f -Value $new -Encoding UTF8
        Write-Output "Updated: $f => relative: $relative"
    }
}
