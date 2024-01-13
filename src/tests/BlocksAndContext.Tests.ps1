
# https://pester.dev/docs/usage/data-driven-tests#execution-is-not-top-down
# Pester v5 introduces a new two phase execution. 
# In the first phase called Discovery, it will run your whole test script from top to bottom. 
# It will also run all ScriptBlocks that you provided to any Describe, Context and BeforeDiscovery. 
# It will collect the ScriptBlocks you provided to It, BeforeAll, BeforeEach, AfterEach and AfterAll, but won't run them until later.
#     Other, is any script outside of It, BeforeAll, BeforeEach, AfterEach and AfterAll. 
#     You see that this code behaves like the new BeforeDiscovery block and thus for clarity on when script will be run its advised to use the BeforeDiscovery.

# Defining a variable directly in the body of the script, will make it available during Discovery, 
# but it won't be available during Run.
param (
    [string] $Param = 'Default Param is available both during Discovery and Run'
)

# Write-Host '-> Top-level script'
$DefinedVariable_In_Script = '$DefinedVariable_In_Script is available during Discovery but not during Run'
# $Param, $DefinedVariable_In_Script | Write-Host

BeforeDiscovery {
    # https://pester.dev/docs/commands/BeforeDiscovery
    # BeforeDiscovery [-ScriptBlock] <ScriptBlock> [<CommonParameters>]
    
    # https://github.com/pester/Pester/blob/acc66a965219a8e70981977289227a211af4c70e/src/Main.ps1#L1525
    # ScriptBlocks are dot sourced and follow boundness rules rules as described here:
    # https://mdgrs.hashnode.dev/scriptblock-and-sessionstate-in-powershell
    # It is not recommended to use Unbound script blocks, they execute with Main.ps1 module's context.
    # Unbound cannot access or modify variables defined in the parent scope. they do not create side effects
    
    # GetNewClosure script blocks get a copy of SessionState from the defining scope and cannot modify variables defined in the parent scope. they do not create side effects but they retain internal state if repeatedly invoked.
    
    $DefinedVariable_In_BeforeDiscovery = '$DefinedVariable_In_BeforeDiscovery is available during Discovery but not during Run'
    # Write-Host '-> Top-level BeforeDiscovery'
    # $Param, $DefinedVariable_In_Script, $DefinedVariable_In_BeforeDiscovery | Write-Host
    $DefinedVariable_In_Script = 'Modified $DefinedVariable_In_Script, it doesn''t matter if a variable is define inside or outside a BeforeDiscovery block'
}
# Write-Host '-> Top-level script after BeforeDiscovery'
# $DefinedVariable_In_Script, $DefinedVariable_In_BeforeDiscovery | Write-Host
# Why use BeforeDiscovery instead of just defining variables in the body of the script?
#    Variables defined inside of BeforeDiscovery block show that this code is running in Discovery intentionally, and not by accident
# https://pester.dev/docs/usage/data-driven-tests#execution-is-not-top-down
# You see that this code behaves like the new BeforeDiscovery block and thus for clarity on when script will be run its advised to use the BeforeDiscovery.
BeforeDiscovery {
    # Before Discovery blocks are executed in the order they are defined
    # Write-Host '-> 2nd top-level Bef oreDiscovery'
    # $Param, $DefinedVariable_In_Script, $DefinedVariable_In_BeforeDiscovery | Write-Host
}

BeforeAll {
    # https://pester.dev/docs/commands/BeforeAll
    # BeforeAll [-Scriptblock] <ScriptBlock> [<CommonParameters>]
    # Write-Host '-> Top-level BeforeAll'
}
BeforeAll {
    # Only the last BeforeAll block will be executed
    # Write-Host '-> Overriding top-level BeforeAll'
    $DefinedVariable_In_BeforeAll = '$DefinedVariable_In_BeforeAll is available during Run'

    if ($Param) {
        # Write-Host "`$Param is available inside a BeforeAll block, $Param"
    }
    else {
        # Write-Host "`$Param is NOT available inside a BeforeAll block"
    }
    if ($DefinedVariable_In_Script) {
        # Write-Host "`$DefinedVariable_In_Script is available inside a BeforeAll block, $DefinedVariable_In_Script"
    }
    else {
        # Write-Host "`$DefinedVariable_In_Script is NOT available inside a BeforeAll block"
    }
    # It block inside a Top level BeforeAll block will throw an error' {}
    Describe 'Describe block inside a Top level BeforeAll block' {
        It 'It block inside a BeforeAll block counts towards NotRun' {
            # Write-Host '-> It Block NotRun'
        }
    }
}
AfterAll {
    # https://pester.dev/docs/commands/AfterAll
    # AfterAll [-Scriptblock] <ScriptBlock> [<CommonParameters>]
    # Write-Host '-> Top-level AfterAll'
}
AfterAll {
    # Only the last AfterAll block will be executed
    # Write-Host '-> Overriding top-level AfterAll'
    if ($Param) {
        # Write-Host "`$Param is available inside a AfterAll block, $Param"
    }
    else {
        # Write-Host "`$Param is NOT available inside a AfterAll block"
    }
    if ($DefinedVariable_In_Script) {
        # Write-Host "`$DefinedVariable_In_Script is available inside a AfterAll block, $DefinedVariable_In_Script"
    }
    else {
        # Write-Host "`$DefinedVariable_In_Script is NOT available inside a AfterAll block"
    }
    # It 'It block inside a Top level AfterAll block will throw an error' {}
    Describe 'Describe block inside a Top level AfterAll block' {
        It 'It block inside a AfterAll block counts towards NotRun' {
            # Write-Host '-> It Block NotRun'
        }
    }
}

# It "Top level It block will throw an error" {}
# BeforeEach "Top level BeforeEach block will throw an error" {}
# AfterEach "Top level AfterEach block will throw an error" {}

$DoSkip = $False 
Describe -Name 'Fully specified Describe block' -Tag 'Tag' -Skip:$DoSkip -ForEach @('item available inside', 'the Describe block', "and in inner It blocks as `$_") -Fixture {
    # https://pester.dev/docs/commands/Describe
    # Describe [-Name] <String> [-Tag <String[]>] [[-Fixture] <ScriptBlock>] [-Skip] [-ForEach <Object>] [<CommonParameters>]
    # Fixture is where we define the tests with It and Before*, After* blocks
    # Write-Host "-> Fully specified Describe block, $_"

    BeforeAll {
        # Write-Host '-> BeforeAll'
        It 'It block inside a BeforeAll block counts towards NotRun' {
            # Write-Host '-> It Block NotRun'
        }
    }
    BeforeEach {
        # https://pester.dev/docs/commands/BeforeEach
        # BeforeEach [-Scriptblock] <ScriptBlock> [<CommonParameters>]
        # Write-Host '-> BeforeEach'
        # It 'It block inside a BeforeEach block will throw an error' {}
    }
    AfterAll {
        # Write-Host '-> AfterAll'
        It 'It block inside a AfterAll block counts towards NotRun' {
            # Write-Host '-> It Block NotRun'
        }
    }
    AfterEach {
        # https://pester.dev/docs/commands/AfterEach
        # AfterEach [-Scriptblock] <ScriptBlock> [<CommonParameters>]
        # Write-Host '-> AfterEach'
        # It 'It block inside a AfterEach block will throw an error' {}
    }

    It -Name 'Fully specified It block' -Tag 'Tag' -ForEach @('item overrides', "outer '-ForEach'", "assigned `$_ for this block") -Skip:$DoSkip -Test {
        # https://pester.dev/docs/commands/It
        # It [-Name] <String> [[-Test] <ScriptBlock>] [-ForEach <Object[]>] [-Tag <String[]>] [<CommonParameters>]
        # It [-Name] <String> [[-Test] <ScriptBlock>] [-ForEach <Object[]>] [-Tag <String[]>] [-Pending] [<CommonParameters>]
        # It [-Name] <String> [[-Test] <ScriptBlock>] [-ForEach <Object[]>] [-Tag <String[]>] [-Skip] [<CommonParameters>]
        # Write-Host '-> Fully specified It block'
        # Write-Host "Access It block's `$_, $_"
        $true | Should -Be $true
    }
    It -Name "It block without '-ForEach'" -Tag 'Tag' -Skip:$DoSkip -Test {
        # Write-Host "-> It block without '-ForEach'"
        # Write-Host "Access Describe block's `$_, $_"
    }
}

Describe 'Minimal Describe block syntax' {
    It 'Minimal It block syntax' {
    
    }
    # It "It blocks cannot have It, Describe, Context blocks nested" {
    #     It "This will throw an error" {}
    #     Describe "This will throw an error" {}
    #     Context "This will throw an error" {}
    # }
    It 'BeforeAll, BeforeEach, AfterEach and AfterAll do not execute and do not count towards NotRun if nested in It block' {
        BeforeAll { Write-Error 'BeforeAll block inside It block' }
        BeforeEach { Write-Error 'BeforeEach block inside It block' }
        AfterEach { Write-Error 'AfterEach block inside It block' }
        AfterAll { Write-Error 'AfterAll block inside It block' }
    }
    It 'Skipped It block' -Skip {
        # Use this parameter to explicitly mark the test to be skipped. 
        # This is preferable to temporarily commenting out a test, because the test remains listed in the output. 
        # Use the Strict parameter of Invoke-Pester to force all skipped tests to fail.
        #     https://github.com/pester/Pester/releases/tag/5.0.1#legacy-parameter-set
        #     The -Strict parameter and -PesterOption are ignored. Strict will possibly be fixed in 5.1.0 as well. -PesterOption is superseded by -Configuration, and you most likely don't need it in your workflow right now.
        # Write-Host "-> It, $Param, $DefinedVariable_In_Script"
    }
    It "'Pending', unfinished, It block" -Pending {
        # -Pending
        # Use this parameter to explicitly mark the test as work-in-progress/not implemented/pending 
        # when you need to distinguish a test that fails because it is not finished yet from a tests 
        # that fail as a result of changes being made in the code base. An empty test, that is a test 
        # that contains nothing except whitespace or comments is marked as Pending by default.
        #    The statement about empty test is not true. Empty test is not marked as pending by default, see below.
        # Write-Host '-> Pending It is not executed and counts as skipped'
    }
    It 'Should automatically marked pending It block but gets executed as a regular test' {}
    It 'Typical It block syntax' {
        # Write-Host "-> It, $Param, $DefinedVariable_In_Script"
    }
}

Describe 'Describe block without explicit -Name and -Fixture' -Tag 'Tag' -Skip:$DoSkip -ForEach @($Param, $DefinedVariable_In_Script, $DefinedVariable_In_BeforeDiscovery) {
    # No need to specify the -Name or -Fixture parameters explicitly, as long as their order is correct.
    # https://pester.dev/docs/commands/Describe#-name
    #    Position: 1
    # https://pester.dev/docs/commands/Describe#-fixture
    #    Position: 2
    BeforeAll {
        It 'It block inside a BeforeAll block counts towards NotRun' {}
    }
    AfterAll {
        It 'It block inside a AfterAll block counts towards NotRun' {}
    }
    It "If script is invoked with inputs that override the defaults, they're not available inside the It block" {
        $Param | Should -BeIn $null, 'Default Param is available both during Discovery and Run'
        if ($Param) {
            # Write-Host "`$Param is available inside the It block, $Param"
        }
        else {
            # Write-Host "`$Param is NOT available inside the It block"
        }
    }
    It "`$DefinedVariable_In_Script and `$DefinedVariable_In_BeforeDiscovery are available inside the It block" {
        $DefinedVariable_In_Script | Should -Be $null
        $DefinedVariable_In_BeforeDiscovery | Should -Be $null
    }
    It "They're only accessible in Discovery but with '-ForEach' it's possible to pass them to the It block" {
        $_ | Should -Not -Be $null
        # Write-Host "-> It Executed with `$_, $_"
    }
    $DefinedVariable_In_Describe = '$DefinedVariable_In_Describe is available during Discovery but not during Run'
    It '$DefinedVariable_In_Describe is not available inside the It block' {
        $DefinedVariable_In_Describe | Should -Be $null
        if ($DefinedVariable_In_Describe) {
            # Write-Host "`$DefinedVariable_In_Describe is available inside the It block, $DefinedVariable_In_Describe"
        }
        else {
            # Write-Host "`$DefinedVariable_In_Describe is NOT available inside the It block"
        }
    }
    It '$DefinedVariable_In_BeforeAll is aviailable inside the It block' {
        $DefinedVariable_In_BeforeAll | Should -Not -Be $null
        if ($DefinedVariable_In_BeforeAll) {
            # Write-Host "`$DefinedVariable_In_BeforeAll is available inside the It block, $DefinedVariable_In_BeforeAll"
        }
        else {
            # Write-Host "`$DefinedVariable_In_BeforeAll is NOT available inside the It block"
        }
    }
}

Context 'Fully specified Context block' -Tag 'Tag' -Skip:$DoSkip -ForEach @(1, 2, 3) {
    # https://pester.dev/docs/commands/Context
    # Context [-Name] <String> [-Tag <String[]>] [[-Fixture] <ScriptBlock>] [-Skip] [-ForEach <Object>] [<CommonParameters>]
    # https://pester.dev/docs/usage/test-file-structure#more-complex-file
    
    # DESCRIBE VS. CONTEXT
    # In almost all cases it does not matter if you use Describe or Context. 
    # They behave the same and are the same function internally. 
    # There are only two places where we distinguish them:
    #     On Mock when -Scope Describe or -Scope Context is used.
    #     In output, when the block information is written to screen.
    #         aka Invoke-Pester -Output Diagnostic
    It 'It block inside context' {}
}

