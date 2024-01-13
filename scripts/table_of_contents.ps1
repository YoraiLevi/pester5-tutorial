Write-Output '# Table of Contents'
Write-Output ''
$base_path = 'src/markdown/'
# $files = Get-ChildItem src/markdown/*.md -Recurse | Sort-Object -Property FullName | ForEach-Object { @{File = $_; RelativePath = [System.IO.Path]::GetRelativePath($base_path, $_.FullName) } }
# $files | ForEach-Object { "1. [$($_.File.BaseName -replace '_',' ')]($(Resolve-Path -Relative $_.File))" }

Get-ChildItem "$base_path/*.md" -Recurse | Sort-Object -Property Directory | ForEach-Object {
    $base_relative_path = [System.IO.Path]::GetRelativePath($base_path, $_.FullName)
    $relative_path = [System.IO.Path]::GetRelativePath('.', $_.FullName)
    $pretty_name = $_.BaseName -replace '_', ' '
    $path_tree = @($base_relative_path -split '\\' | ForEach-Object { $i = 0 } { '  ' * $i + "- $_"; $i++ })
    $path_tree[-1] = '  ' * ($i - 1) + "- [$pretty_name]($([uri]::EscapeDataString($relative_path)))  "
    $path_tree
} | Select-Object -Unique
# .\scripts\table_of_contents.ps1 > .\TABLE_OF_CONTENTS.md