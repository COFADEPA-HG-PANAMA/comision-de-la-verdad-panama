$root = 'C:\Users\RUSSO\Documents\website\TESTWEB'
Get-ChildItem -Path $root -Include *.htm,*.html -Recurse | ForEach-Object {
    $f = $_.FullName
    $text = Get-Content $f -Raw -ErrorAction Stop
    # If already has shortcut icon, skip
    if ($text -match 'rel="shortcut icon"' -or $text -match "rel='shortcut icon'") {
        return
    }
    # Try to find absolute favicon line and insert shortcut after it
    if ($text -match '/favicon.ico') {
        $new = [regex]::Replace($text, '(/favicon.ico" type="image/x-icon">)\s*', '$1' + [Environment]::NewLine + "<link rel='shortcut icon' href='/favicon.ico' type='image/x-icon'>" + [Environment]::NewLine)
        if ($new -ne $text) {
            if (!(Test-Path "$f.bak")) { Copy-Item $f "$f.bak" -Force }
            Set-Content -Path $f -Value $new -Encoding UTF8
            Write-Output "Inserted shortcut: $f"
        }
    }
}
