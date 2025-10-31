# PowerShell script to insert favicon/link tags into all .htm/.html files
$root = "C:\Users\RUSSO\Documents\website\TESTWEB"
$faviconBlock = @'
<link rel="icon" href="/favicon.ico" type="image/x-icon">
<link rel="shortcut icon" href="/favicon.ico" type="image/x-icon">
<link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
'@

$files = Get-ChildItem -Path $root -Recurse -Include *.htm,*.html -File -ErrorAction SilentlyContinue
$modified = @()
foreach ($f in $files) {
    try {
        $text = Get-Content -Raw -Encoding UTF8 $f.FullName
    } catch {
        Write-Host "SKIP (read error): $($f.FullName)"
        continue
    }
    if ($text -match '(?is)rel\s*=\s*"(?:icon|shortcut icon)') { continue }
    if ($text -match '(?is)</head>') {
        $new = [regex]::Replace($text, '(?is)</head>', "$faviconBlock`n</head>")
    } elseif ($text -match '(?is)</title>') {
        $new = [regex]::Replace($text, '(?is)</title>', "</title>`n$faviconBlock")
    } else {
        Write-Host "SKIP (no </head> or </title>): $($f.FullName)"
        continue
    }
    # backup
    Copy-Item -Path $f.FullName -Destination ($f.FullName + '.bak') -Force
    # write back
    Set-Content -Path $f.FullName -Value $new -Encoding UTF8
    $modified += $f.FullName
}
Write-Host "Done. Modified $($modified.Count) files."
if ($modified.Count -gt 0) { Write-Host "Modified files:"; $modified | Select-Object -First 200 | ForEach-Object { Write-Host $_ } }
