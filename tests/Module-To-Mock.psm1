$ModuleVariable = 'ModuleVariable'
function Public-Module-Function {
    param(
        [System.IO.FileInfo]$Path = '.',
        [ValidateSet('Value', 'Different Value')]
        [string]$ValidatedParameter = 'Value',
        [ValidateSet('Value', 'Different Value')]
        [string]$AnotherValidatedParameter = 'Value',
        $Param
    )
    $out = Private-Module-Function -Path $Path -ValidatedParameter $ValidatedParameter
    "Public-Module-Function: $out"
}

function Private-Module-Function {
    param(
        [System.IO.FileInfo]$Path = '.',
        [ValidateSet('Value', 'Different Value')]
        [string]$ValidatedParameter = 'Value',
        [ValidateSet('Value', 'Different Value')]
        [string]$AnotherValidatedParameter = 'Value',
        $Param
    )
    "Private-Module-Function: $ValidatedParameter, $($Path.FullName)"
}

Export-ModuleMember -Function Public-Module-Function