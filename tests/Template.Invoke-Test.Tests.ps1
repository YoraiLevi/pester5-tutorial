BeforeDiscovery {
    $Arguments = @(
        @("Provided array entry is available during Discovery and can be bounded with '-ForEach' and `$PSBoundParameters (see script)"),
        @("Provided array entry is available during Discovery and can be bounded with '-ForEach' and `$PSBoundParameters (see script)", 'more args'),
        @{Param = 'Provided hashtable entry is available both during Discovery and Run' },
        @{Param = 'Provided hashtable entry is available both during Discovery and Run' ; Another_Param = 'Extra entries are available both during Discovery and Run' }
    )
}
Describe 'Invoke Parameterized Tests: <_> <Param>' -ForEach $Arguments {
    & "$PSScriptRoot/Template.Test.Tests.ps1" @_
}