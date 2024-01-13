BeforeDiscovery {
    $values = ,'Provided Param 1 is available','Provided Param 2 is available'
}
Describe 'Invoke Parameterized Tests' -ForEach $values {
    & "$PSScriptRoot/BlocksAndContext.Tests.ps1" $_
    & "$PSScriptRoot/Paramaterized.ps1" $_
}