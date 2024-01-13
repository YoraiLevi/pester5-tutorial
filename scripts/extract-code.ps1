Get-ChildItem *.md -Recurse | ForEach-Object {
    $_.DirectoryName | Set-Location
    $filename = $null
    # get code files
    $code = Get-Content $_ | codedown ps1 | ForEach-Object {
        if ($_ -match '\s*#\s+(.+)') {
            $filename = $Matches[1]
        }
        elseif ($filename) {
            @{Name = $filename; Content = $_ }
        }
    }
    # write code files
    $groups = $code | Group-Object -Property Name
    $groups | Select-Object -ExpandProperty Name | Clear-Content -ErrorAction SilentlyContinue
    $groups | ForEach-Object {
      echo "Writing $($_.Name): $($_.Count) lines"
      $_.Group | ForEach-Object {
        echo "  $($_.Content)"
        $_.Content >> $_.Name 
      }
  }
}