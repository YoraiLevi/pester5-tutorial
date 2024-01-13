# https://pester.dev/docs/usage/data-driven-tests#execution-is-not-top-down
#* Pester v5 introduces a new two phase execution. 
#* In the first phase called Discovery, it will run your whole test script from top to bottom. 
#* It will also run all ScriptBlocks that you provided to any Describe, Context and BeforeDiscovery. 
#* It will collect the ScriptBlocks you provided to It, BeforeAll, BeforeEach, AfterEach and AfterAll, but won"t run them until later.
#*     Other, is any script outside of It, BeforeAll, BeforeEach, AfterEach and AfterAll. 
#*     You see that this code behaves like the new BeforeDiscovery block and thus for clarity on when script will be run its advised to use the BeforeDiscovery.

#* Defining a variable directly in the body of the script, will make it available during Discovery, 
#* but it won"t be available during Run.

#! When defining Pester blocks It"s highly recommended to use *Bound* ScriptBlocks, ScriptBlocks are dot sourced and follow the boundness rules as described here:
# https://github.com/pester/Pester/blob/acc66a965219a8e70981977289227a211af4c70e/src/Main.ps1#L1525
# https://mdgrs.hashnode.dev/scriptblock-and-sessionstate-in-powershell
#! It is not recommended to use Unbound ScriptBlocks, generally Unbound do not access or modify variables defined in the creating scope, ie this test script.
#! GetNewClosure script blocks get a copy of SessionState from the defining scope and cannot modify variables defined in the parent scope. however they retain internal state if invoked repeatedly.

param (
    [string] $DefinedVariable_In_Param = 'Default param value is available both during Discovery and Run'
)

function DefinedFunction_In_Script {
    param(
        $Currently_Executing
    )
    Write-Host "$Currently_Executing"
    Write-Host "`tPreviously_Executed: $Previously_Executed"
    (Get-Variable 'DefinedVariable_In*') | ForEach-Object { "`t$($_.Name): $($_.Value)" } | Write-Host
    $script:Previously_Executed = $Currently_Executing
}
$DefinedVariable_In_Script = 'available ONLY during Discovery'
DefinedFunction_In_Script '-> Script, this is executed during Discovery'
BeforeDiscovery {
    $DefinedVariable_In_BeforeDiscovery = 'available ONLY during Discovery'
    DefinedFunction_In_Script '-> BeforeDiscovery, this is executed during Discovery'
    # it doesn"t matter if a variable is defined inside or outside a BeforeDiscovery
    $DefinedVariable_In_Script = 'Modified -> BeforeDiscovery'
}
DefinedFunction_In_Script '-> Script After BeforeDiscovery'

BeforeAll {
    function DefinedFunction_In_BeforeAll {
        param(
            $Currently_Executing
        )
        Write-Host "$Currently_Executing"
        Write-Host "`tPreviously_Executed: $Previously_Executed"
        (Get-Variable 'DefinedVariable_In*') | ForEach-Object { "`t$($_.Name): $($_.Value)" } | Write-Host
        $script:Previously_Executed = $Currently_Executing
    }
    $DefinedVariable_In_BeforeAll = 'available during Run'
    DefinedFunction_In_BeforeAll '-> BeforeAll, this is executed during Run'
}
DefinedFunction_In_Script '-> Script After BeforeAll definition, but before BeforeAll execution'

AfterAll {
    $DefinedVariable_In_Describe_AfterAll = 'available during Run'
    DefinedFunction_In_BeforeAll '-> AfterAll, this is executed during Run'
}
Write-Host "`tDefining -> Describe"
Describe 'Describe' -ForEach @{DefinedVariable_In_DescribeForEach = 'available during Run' } {
    $DefinedVariable_In_Describe = 'available ONLY during Discovery'
    DefinedFunction_In_Script '-> Describe, this is executed during Discovery'
    Write-Host "`tDefining -> Describe -> BeforeAll"
    BeforeAll {
        $DefinedVariable_In_Describe_BeforeAll = 'available during Run'
        DefinedFunction_In_BeforeAll '-> Describe -> BeforeAll, this is executed during Run'
    }
    Write-Host "`tDefining -> Describe -> BeforeEach"
    BeforeEach {
        $DefinedVariable_In_Describe_BeforeEach = 'available during Run'
        DefinedFunction_In_BeforeAll '-> Describe -> BeforeEach, this is executed during Run'
    }
    Write-Host "`tDefining -> Describe -> AfterEach"
    AfterEach {
        $DefinedVariable_In_Describe_AfterEach = 'available during Run'
        DefinedFunction_In_BeforeAll '-> Describe -> AfterEach, this is executed during Run'
    }
    Write-Host "`tDefining -> Describe -> AfterAll"
    AfterAll {
        $DefinedVariable_In_Describe_AfterAll = 'available during Run'
        DefinedFunction_In_BeforeAll '-> Describe -> AfterAll, this is executed during Run'
    }
    Write-Host "`tDefining -> Describe -> It 1"
    It 'It 1' {
        $DefinedVariable_In_Describe_It_1 = 'available during Run'
        DefinedFunction_In_BeforeAll '-> Describe -> It 1, this is executed during Run'
    }
    Write-Host "`tDefining -> Describe -> It 2"
    It 'It 2' {
        $DefinedVariable_In_Describe_It_2 = 'available during Run'
        DefinedFunction_In_BeforeAll '-> Describe -> It 2, this is executed during Run'
    }

    Write-Host "`tDefining -> Describe -> Describe"
    Describe 'Nested Describe' {
        $DefinedVariable_In_Describe_Describe = 'available ONLY during Discovery'
        DefinedFunction_In_Script '-> Describe -> Describe, this is executed during Discovery'
        Write-Host "`tDefining -> Describe -> Describe -> BeforeAll"
        BeforeAll {
            $DefinedVariable_In_Describe_Describe_BeforeAll = 'available during Run'
            DefinedFunction_In_BeforeAll '-> Describe -> Describe -> BeforeAll, this is executed during Run'
        }
        Write-Host "`tDefining -> Describe -> Describe -> BeforeEach"
        BeforeEach {
            $DefinedVariable_In_Describe_Describe_BeforeEach = 'available during Run'
            DefinedFunction_In_BeforeAll '-> Describe -> Describe -> BeforeEach, this is executed during Run'
        }
        Write-Host "`tDefining -> Describe -> Describe -> AfterEach"
        AfterEach {
            $DefinedVariable_In_Describe_Describe_AfterEach = 'available during Run'
            DefinedFunction_In_BeforeAll '-> Describe -> Describe -> AfterEach, this is executed during Run'
        }
        Write-Host "`tDefining -> Describe -> Describe -> AfterAll"
        AfterAll {
            $DefinedVariable_In_Describe_Describe_AfterAll = 'available during Run'
            DefinedFunction_In_BeforeAll '-> Describe -> Describe -> AfterAll, this is executed during Run'
        }
        It 'Describe It 1' {
            $DefinedVariable_In_Describe_Describe_It_1 = 'available during Run'
            DefinedFunction_In_BeforeAll '-> Describe -> Describe -> It 1, this is executed during Run'
        }
        It 'Describe It 2' {
            $DefinedVariable_In_Describe_Describe_It_2 = 'available during Run'
            DefinedFunction_In_BeforeAll '-> Describe -> Describe -> It 2, this is executed during Run'
        }
    }
    Context 'Nested Context' {
        $DefinedVariable_In_Describe_Context = 'available ONLY during Discovery'
        DefinedFunction_In_Script '-> Describe -> Context, this is executed during Discovery'
        Write-Host "`tDefining -> Describe -> Context -> BeforeAll"
        BeforeAll {
            $DefinedVariable_In_Describe_Describe_BeforeAll = 'available during Run'
            DefinedFunction_In_BeforeAll '-> Describe -> Context -> BeforeAll, this is executed during Run'
        }
        Write-Host "`tDefining -> Describe -> Context -> BeforeEach"
        BeforeEach {
            $DefinedVariable_In_Describe_Describe_BeforeEach = 'available during Run'
            DefinedFunction_In_BeforeAll '-> Describe -> Context -> BeforeEach, this is executed during Run'
        }
        Write-Host "`tDefining -> Describe -> Context -> AfterEach"
        AfterEach {
            $DefinedVariable_In_Describe_Describe_AfterEach = 'available during Run'
            DefinedFunction_In_BeforeAll '-> Describe -> Context -> AfterEach, this is executed during Run'
        }
        Write-Host "`tDefining -> Describe -> Context -> AfterAll"
        AfterAll {
            $DefinedVariable_In_Describe_Describe_AfterAll = 'available during Run'
            DefinedFunction_In_BeforeAll '-> Describe -> Context -> AfterAll, this is executed during Run'
        }
        It 'Context It 1' {
            $DefinedVariable_In_Describe_Describe_It_1 = 'available during Run'
            DefinedFunction_In_BeforeAll '-> Describe -> Context -> It 1, this is executed during Run'
        }
        It 'Context It 2' {
            $DefinedVariable_In_Describe_Describe_It_2 = 'available during Run'
            DefinedFunction_In_BeforeAll '-> Describe -> Context -> It 2, this is executed during Run'
        }
    }
    Write-Host "`tDefining -> Describe -> It After Context definitions"
    It 'It 3' {
        $DefinedVariable_In_Describe_It_3 = 'available during Run'
        DefinedFunction_In_BeforeAll '-> Describe -> It 3, this is executed during Run'
    }
    DefinedFunction_In_Script '-> Describe After It definitions, but before Run phase execution'
}
DefinedFunction_In_Script '-> Script After Describe execution'

Describe 'Making sure params are available in Run regardless of array or hashtable usage' -ForEach $PSBoundParameters {
    DefinedFunction_In_Script '-> Describe, Making sure params are available in Run regardless of array or hashtable usage'
    It 'It 4' {
        $DefinedVariable_In_Describe_It_4 = 'available during Run'
        DefinedFunction_In_BeforeAll '-> Describe -> It 4, this is executed during Run'
    }
}