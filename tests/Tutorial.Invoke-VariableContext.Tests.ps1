BeforeDiscovery {
    $Arguments = @(
        @("Provided array entry is available during Discovery and can be bounded with '-ForEach' and `$PSBoundParameters (see script)"),
        @("Provided array entry is available during Discovery and can be bounded with '-ForEach' and `$PSBoundParameters (see script)", 'more args'),
        @{DefinedVariable_In_Param = 'Provided hashtable entry is available both during Discovery and Run' },
        @{DefinedVariable_In_Param = 'Provided hashtable entry is available both during Discovery and Run' ; DefinedVariable_In_Invoking = 'Extra entries are available both during Discovery and Run' }
    )
}
BeforeAll {
    Write-Host '-------------------Run phase execution begins-------------------'
}
AfterAll {
    Write-Host '-------------------Run phase execution ends-------------------'
}
# $Arguments | ForEach-Object {
#     & "$PSScriptRoot/Tutorial.VariableContext.Tests.ps1" @_
# }
#* Wraping the test script with a Describe block allows for the use of BeforeAll and AfterAll blocks per each test script invocation rather than once for the entire loop.
#* This is because the Describe block creates a new scope per iteration of the loop.
#* A side effect of this is that hashtable entries become available during Discovery and Run rather than just during Discovery like with the array entries.
#* This is a result of how Pester handles the "-ForEach" parameter internally. It is not a bug, but an intended feature.
Describe 'Invoke Parameterized Tests: <_ | Out-String>' -ForEach $Arguments {
    Write-Host "Discovery phase: `$_: $($_ | Out-String)"
    & "$PSScriptRoot/Tutorial.VariableContext.Tests.ps1" @_
    #! Not recommended! it"s possible to override the BeforeAll and AfterAll blocks from the test script.
    # BeforeAll {
    #     Write-Host "Overriding the BeforeAll block from the test script"
    # }
    # AfterAll {
    #     Write-Host "Overriding the AfterAll block from the test script"
    # }
    #! Not recommended! executing another test script from within this loop with BeforeAll and AfterAll blocks will override the current BeforeAll and AfterAll blocks.
    # & "$PSScriptRoot/Tutorial.BreakVariableContext.Tests.ps1" @_
}
