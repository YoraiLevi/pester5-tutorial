# https://pester.dev/docs/usage/data-driven-tests#execution-is-not-top-down
#* Pester v5 introduces a new two phase execution. 
#* In the first phase called Discovery, it will run your whole test script from top to bottom. 
#* It will also run all ScriptBlocks that you provided to any Describe, Context and BeforeDiscovery. 
#* It will collect the ScriptBlocks you provided to It, BeforeAll, BeforeEach, AfterEach and AfterAll, but won't run them until later.
#*     Other, is any script outside of It, BeforeAll, BeforeEach, AfterEach and AfterAll. 
#*     You see that this code behaves like the new BeforeDiscovery block and thus for clarity on when script will be run its advised to use the BeforeDiscovery.

Write-Host '-> Top-level script'

BeforeDiscovery {
    # https://pester.dev/docs/commands/BeforeDiscovery
    #? BeforeDiscovery [-ScriptBlock] <ScriptBlock> [<CommonParameters>]
    Write-Host '-> Top-level BeforeDiscovery'
    #* BeforeDiscovery blocks are "transparent" it's as if the code inside the block was written directly in the body of the script.
    #* Why use BeforeDiscovery instead of just defining variables in the body of the script?
    #*    Variables defined inside of BeforeDiscovery block show that this code is running in Discovery intentionally, and not by accident
    # https://pester.dev/docs/usage/data-driven-tests#execution-is-not-top-down
    #* You see that this code behaves like the new BeforeDiscovery block and thus for clarity on when script will be run its advised to use the BeforeDiscovery.
}
Write-Host '-> Top-level script after first BeforeDiscovery'
BeforeDiscovery {
    # Before Discovery blocks are executed in the order they are defined
    Write-Host '-> 2nd top-level BeforeDiscovery'
}
Write-Host '-> Top-level script after 2nd BeforeDiscovery'
Describe 'BeforeDiscovery can execute inside Describe' {
    BeforeDiscovery {
        Write-Host '-> BeforeDiscovery inside Describe'
    }
}
BeforeAll {
    # https://pester.dev/docs/commands/BeforeAll
    #? BeforeAll [-Scriptblock] <ScriptBlock> [<CommonParameters>]
    Write-Host '-> Top-level BeforeAll'
}
BeforeAll {
    # Only the last BeforeAll block will be executed
    Write-Host '-> Overriding top-level BeforeAll'
    #! It block inside a Top level BeforeAll block will throw an error' {}
    Describe 'Describe block inside a Top level BeforeAll block' {
        # It blocks inside BeforeAll or AfterAll are not executed and DONT count towards NotRun
        It 'It block inside a BeforeAll block DONT execute and count towards NotRun' {
            Write-Error '-> It Block NotRun'
        }
    }
}

#! BeforeEach "Top level BeforeEach block will throw an error" {}
#! It "Top level It block will throw an error" {}
#! AfterEach "Top level AfterEach block will throw an error" {}

AfterAll {
    # https://pester.dev/docs/commands/AfterAll
    #? AfterAll [-Scriptblock] <ScriptBlock> [<CommonParameters>]
    Write-Host '-> Top-level AfterAll'
}
AfterAll {
    # Only the last AfterAll block will be executed
    Write-Host '-> Overriding top-level AfterAll'
    # ! It 'It block inside a Top level AfterAll block will throw an error' {}
    Describe 'Describe block inside a Top level AfterAll block' {
        # It blocks inside BeforeAll or AfterAll are NOT executed and DONT count towards NotRun
        It 'It block inside a AfterAll block DONT execute and count towards NotRun' {
            Write-Error '-> It Block NotRun'
        }
    }
}

Describe 'Top level Describe block' {
    # https://pester.dev/docs/commands/Describe
    #? Describe [-Name] <String> [-Tag <String[]>] [[-Fixture] <ScriptBlock>] [-Skip] [-ForEach <Object>] [<CommonParameters>]
    Write-Host '-> Top level Describe block'
    BeforeAll {
        Write-Host '-> BeforeAll'
    }
    BeforeAll {
        # Only the last BeforeAll block will be executed
        Write-Host '-> Overriding BeforeAll'
        # It blocks inside BeforeAll or AfterAll are NOT executed and DONT count towards NotRun
        It 'It block inside a BeforeAll block DONT execute and count towards NotRun' {
            Write-Error '-> It Block NotRun'
        }
    }
    BeforeEach {
        # https://pester.dev/docs/commands/BeforeEach
        #? BeforeEach [-Scriptblock] <ScriptBlock> [<CommonParameters>]
        Write-Host '-> BeforeEach'
        #! It 'It block inside a BeforeEach block will throw an error' {}
    }
    AfterAll {
        Write-Host '-> AfterAll'
    }
    AfterAll {
        # Only the last BeforeAll block will be executed
        Write-Host '-> Overriding AfterAll'
        # It blocks inside BeforeAll or AfterAll are NOT executed and DONT count towards NotRun
        It 'It block inside a AfterAll block DONT execute and count towards NotRun' {
            Write-Error '-> It Block NotRun'
        }
    }
    AfterEach {
        # https://pester.dev/docs/commands/AfterEach
        #? AfterEach [-Scriptblock] <ScriptBlock> [<CommonParameters>]
        Write-Host '-> AfterEach'
        #! It 'It block inside a AfterEach block will throw an error' {}
    }
    #! It "It blocks cannot have It, Describe, Context blocks nested" {
    #!     It "This will throw an error" {}
    #!     Describe "This will throw an error" {}
    #!     Context "This will throw an error" {}
    #! }
    It 'BeforeAll, BeforeEach, AfterEach and AfterAll DONT execute and DONT count towards NotRun if nested in It block' {
        # https://pester.dev/docs/commands/It
        #? It [-Name] <String> [[-Test] <ScriptBlock>] [-ForEach <Object[]>] [-Tag <String[]>] [<CommonParameters>]
        #? It [-Name] <String> [[-Test] <ScriptBlock>] [-ForEach <Object[]>] [-Tag <String[]>] [-Pending] [<CommonParameters>]
        #? It [-Name] <String> [[-Test] <ScriptBlock>] [-ForEach <Object[]>] [-Tag <String[]>] [-Skip] [<CommonParameters>]
        BeforeAll { Write-Error 'BeforeAll block inside It block' }
        BeforeEach { Write-Error 'BeforeEach block inside It block' }
        AfterEach { Write-Error 'AfterEach block inside It block' }
        AfterAll { Write-Error 'AfterAll block inside It block' }
        #* This makes sense, It's impossible to define a test inside a test so the blocks inside It block are never executed
    }
    It 'It block inside a top-level Describe block' {
        Write-Host '-> It block inside a top-level Describe block'
    }
    Describe 'Nested Describe block' {
        Write-Host '-> Nested Describe block'
        It 'It block inside a nested Describe block' {
            Write-Host '-> It block inside a nested Describe block'
        }
    }
    Context 'Nested Context block' {
        # https://pester.dev/docs/commands/Context
        #? Context [-Name] <String> [-Tag <String[]>] [[-Fixture] <ScriptBlock>] [-Skip] [-ForEach <Object>] [<CommonParameters>]

        # https://pester.dev/docs/usage/test-file-structure#more-complex-file
        #* DESCRIBE VS. CONTEXT
        #* In almost all cases it does not matter if you use Describe or Context. 
        #* They behave the same and are the same function internally. 
        #* There are only two places where we distinguish them:
        #*     On Mock when -Scope Describe or -Scope Context is used.
        #*     In output, when the block information is written to screen.
        #*         aka Invoke-Pester -Output Diagnostic
        It 'It block inside a nested Describe block' {
            Write-Host '-> It block inside a nested Context block'
        }
    }
    Describe 'Nested Before*, After* blocks are executed in addition to outer the Before*, After* blocks' {
        BeforeAll {
            Write-Host '-> Nested BeforeAll'
        }
        BeforeEach {
            Write-Host '-> Nested BeforeEach'
        }
        AfterEach {
            Write-Host '-> Nested AfterEach'
        }
        AfterAll {
            Write-Host '-> Nested AfterAll'
        }
        It 'It block 1' {
            Write-Host '-> It block 1'
        }
        It 'It block 2' {
            Write-Host '-> It block 2'
        }
    }
}

Describe 'Skipping and Pending' -Tag 'SkipPending' {
    It 'Skipped It block' -Skip {
        #* Use this parameter to explicitly mark the test to be skipped. 
        #* This is preferable to temporarily commenting out a test, because the test remains listed in the output. 
        #* Use the Strict parameter of Invoke-Pester to force all skipped tests to fail.
        #     https://github.com/pester/Pester/releases/tag/5.0.1#legacy-parameter-set
        #*     The -Strict parameter and -PesterOption are ignored. Strict will possibly be fixed in 5.1.0 as well. -PesterOption is superseded by -Configuration, and you most likely don't need it in your workflow right now.
        Write-Host '-> It is NOT executed and counts as skipped'
    }
    It "'Pending', unfinished, It block" -Pending {
        # -Pending
        #* Use this parameter to explicitly mark the test as work-in-progress/not implemented/pending 
        #* when you need to distinguish a test that fails because it is not finished yet from a tests 
        #* that fail as a result of changes being made in the code base. An empty test, that is a test 
        #* that contains nothing except whitespace or comments is marked as Pending by default.
        #!    The statement about empty test is not true. Empty test is not marked as pending by default, see below.
        Write-Host '-> Pending It is NOT executed and counts as skipped'
    }
    It 'Should automatically marked pending It block but gets executed' {}
    Describe 'Skip and entire describe block' -Skip {
        It 'It block 1' {
            Write-Host '-> It block 1 is NOT executed and counts as skipped'
        }
        It 'It block 2' {
            Write-Host '-> It block 2 is NOT executed and counts as skipped'
        }
    }
}

Describe 'Parameterizing' -Tag 'Parameterizing' {
    Describe "Parameterizing tests with Describe '-Foreach': array of hashtable/objects" -ForEach @{ foo = 'foo' }, @{ foo = 'foo'; bar = 'bar' }, 'baz', 'qux' {
        #* The describe block iterates through the array of objects provided and executes this scriptblock each time.
        #* In general the objects are available as $_
        #* Hashtables are also splatted and have their keys as $named variables inside the Describe block.

        #* Generating It blocks dynamically
        if ($_ -isnot [hashtable]) {
            It '$_ is available for the describe block' {
                $_ | Should -BeIn 'baz', 'qux'
                Write-Host "`$_ is available inside the It block, $_"
            }
        }
        if ($foo) {
            It 'Foo is available for the describe block' {
                $foo | Should -Be 'foo'
                Write-Host "`$foo is available inside the It block, $foo"
            }
        }
        if ($bar) {
            It 'Bar is available for the describe block' {
                $bar | Should -Be 'bar'
                Write-Host "`$bar is available inside the It block, $bar"
            }
        }
        #* Single It block with multiple assertions
        It 'Single It block with multiple assertions' {
            if ($_ -isnot [hashtable]) {
                $_ | Should -BeIn 'baz', 'qux'
                Write-Host "`$_ is available inside the It block, $_"
            }
            if ($foo) {
                $foo | Should -Be 'foo'
                Write-Host "`$foo is available inside the It block, $foo"
            }
            if ($bar) {
                $bar | Should -Be 'bar'
                Write-Host "`$bar is available inside the It block, $bar"
            }
        }
    }
    It "Parameterizing tests with It '-Foreach': array of hashtable/objects" -ForEach @{ foo = 'foo' }, @{ foo = 'foo'; bar = 'bar' }, 'baz', 'qux' {
        #* The describe block iterates through the array of objects provided and executes this scriptblock each time.
        #* In general the objects are available as $_
        #* Hashtables are also splatted and have their keys as $named variables inside the It block.
        if ($_ -isnot [hashtable]) {
            $_ | Should -BeIn 'baz', 'qux'
            Write-Host "`$_ is available inside the It block, $_"
        }
        if ($foo) {
            $foo | Should -Be 'foo'
            Write-Host "`$foo is available inside the It block, $foo"
        }
        if ($bar) {
            $bar | Should -Be 'bar'
            Write-Host "`$bar is available inside the It block, $bar"
        }
    }
}

Describe 'Using Tags' -Tag 'Tagging' {
    #* Tags from parent blocks are inherited by child blocks
    #* Pester-Invoke's '-Tag' and '-ExcludeTag' parameters can be used to filter which tests are run.
    #* '-Tag' inclusive (set union), '-ExcludeTag' is redusive (set difference).
    #* `Invoke-Pester -Tag 'Tagging' ` will execute all blocks(!) with 'Tagging' tag
    
    #* For this test the union of 'Tagging','Tag1 is the same as 'Tagging',
    #* `Invoke-Pester -Tag 'Tagging','Tag1' ` will execute all blocks(!) with Tagging tag

    #* `Invoke-Pester -Tag 'Tagging' -ExcludeTag 'Tag2' ` will execute all blocks(!) with 'Tagging' tag that don't have 'Tag2' tag
    #* eg, only blocks ONLY with 'Tag1' tag
    #* -> It block with tag 1
    #* -> It block with tag 1 nested in Describe block with tag 1

    #* `Invoke-Pester -Tag 'Tag1' -ExcludeTag 'Tag1' ` executes nothing (empty set)
    
    It 'It block with tag 1' -Tag 'Tag1' {
        #* Invoke-Pester -Tag 'Tag1' 
        #* Invoke-Pester -Tag 'Tagging' -ExcludeTag 'Tag2'
        Write-Host '-> It block with tag 1'
    }
    It 'It block with tag 2' -Tag 'Tag2' {
        #* Invoke-Pester -Tag 'Tag2' 
        #* Invoke-Pester -Tag 'Tagging' -ExcludeTag 'Tag1'
        Write-Host '-> It block with tag 2'
    }
    It 'It block with multiple tags' -Tag 'Tag1', 'Tag2' {
        #* Invoke-Pester -Tag 'Tag1' 
        #* Invoke-Pester -Tag 'Tag2'
        Write-Host '-> It block with multiple tags'
    }
    Describe "Childrem blocks will also have 'Tag1'" -Tag 'Tag1' {
        Write-Host '-> Nested Describe block with tag 1'
        It 'It block with tag 1' -Tag 'Tag1' {
            #* Invoke-Pester -Tag 'Tag1' 
            #* Invoke-Pester -Tag 'Tagging' -ExcludeTag 'Tag2'
            Write-Host '-> It block with tag 1 nested in Describe block with tag 1'
        }
        It 'It block with tag 2 that inherits tag 1 from parent Describe' -Tag 'Tag2' {
            #* Invoke-Pester -Tag 'Tag1' 
            #* Invoke-Pester -Tag 'Tag2' 
            Write-Host '-> It block with tag 2 nested in Describe block with tag 1'
        }
        It 'It block with multiple tags' -Tag 'Tag1', 'Tag2' {
            #* Invoke-Pester -Tag 'Tag1' 
            #* Invoke-Pester -Tag 'Tag2' 
            Write-Host '-> It block with multiple tags nested in Describe block with tag 1'
        }
    }
    Describe "Childrem blocks will also have 'Tag2'" -Tag 'Tag2' {
        Write-Host '-> Nested Describe block with tag 2'
        It 'It block with tag 1 that inherits tag 2 from parent Describe' -Tag 'Tag1' {
            #* Invoke-Pester -Tag 'Tag1' 
            #* Invoke-Pester -Tag 'Tag2' 
            Write-Host '-> It block with tag 1 nested in Describe block with tag 2'
        }
        It 'It block with tag 2' -Tag 'Tag2' {
            #* Invoke-Pester -Tag 'Tag2' 
            #* Invoke-Pester -Tag 'Tagging' -ExcludeTag 'Tag1'
            Write-Host '-> It block with tag 2 nested in Describe block with tag 2'
        }
        It 'It block with multiple tags' -Tag 'Tag1', 'Tag2' {
            #* Invoke-Pester -Tag 'Tag1' 
            #* Invoke-Pester -Tag 'Tag2' 
            Write-Host '-> It block with multiple tags nested in Describe block with tag 2'
        }
    }
}