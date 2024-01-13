Describe 'Mocking Example' {
    # Mock [[-CommandName] <String>] [[-MockWith] <ScriptBlock>] [-Verifiable] [[-ParameterFilter] <ScriptBlock>]
    #      [[-ModuleName] <String>] [[-RemoveParameterType] <String[]>] [[-RemoveParameterValidation] <String[]>]
    #      [<CommonParameters>]
    BeforeAll {
        function Mock-Function { param($Param) 'Function' }
        function First-Function { 'First-Function called' }
        function Second-Function { 'Second-Function called' }
        
        Mock Mock-Function { 'Mock-Function called' } # Mocks the function Mock-Function
        Mock-Function 

        Import-Module -Name "$PSScriptRoot/Module-To-Mock.psm1" 
        # Example of calling the original function

    }
    AfterAll {
        # RuntimeException: Multiple script or manifest modules named 'Module-To-Mock' are currently loaded. Make sure to remove any extra copies of the module from your session before testing.
        Remove-Module -Name Module-To-Mock
    }
    It 'Example of calling the original function non-mocked behavior' {
        Public-Module-Function | Should -Not -Be $null
        { Public-Module-Function -Path (New-Object System.Object) } | Should -Throw -ExpectedMessage '*Cannot process argument transformation on parameter*'
        { Public-Module-Function -ValidatedParameter 'Not in Set' } | Should -Throw -ExpectedMessage '*Cannot validate argument on parameter*'
    }
    It 'Fully qualified mock' {

        # Needs to be called without '-ModuleName Module-To-Mock'
        Mock -CommandName Public-Module-Function -MockWith { 'Public-Module-Function called' } -Verifiable:$false -ParameterFilter { $ValidatedParameter -eq 'Not in Set' } -RemoveParameterType @('Path') -RemoveParameterValidation @('ValidatedParameter')
        Public-Module-Function -Path 'C:\Temp\Public-Module-Function.txt' -ValidatedParameter 'Not in Set'
        Should -Invoke Public-Module-Function -Exactly -Times 1

        Public-Module-Function -Path (New-Object System.Object) -ValidatedParameter 'Not in Set'
        Should -Invoke Public-Module-Function -Exactly -Times 2

        $DefinedVariable_In_It = '$DefinedVariable_In_It is available in the It block but not in the Mock block'
        
        # Mock Private-Module-Function { Write-Host 'Private-Module-Function' }
        # CommandNotFoundException: Could not find Command Private-Module-Function

        # https://pester.dev/docs/migrations/v4-to-v5#avoid-putting-in-inmodulescope-around-your-describe-and-it-blocks
        # Avoid putting in InModuleScope around your Describe and It blocks
        InModuleScope -ModuleName Module-To-Mock -Parameters @{Passed_Parameter = $DefinedVariable_In_It } -ArgumentList @('These are', 'available', 'in this block') -ScriptBlock {
            # InModuleScope [-ModuleName] <String> [-ScriptBlock] <ScriptBlock> [[-Parameters] <Hashtable>] [[-ArgumentList] <Object[]>] [<CommonParameters>]
            # This example shows two ways of using -Parameters to pass variables created in a testfile into the module scope
            # where the scriptblock provided to InModuleScope is executed. No variables from the outside are available inside
            # the scriptblock without explicitly passing them in using -Parameters or -ArgumentList.
            Mock -CommandName Private-Module-Function -MockWith { 'Private-Module-Function was called' } -Verifiable -ModuleName Module-To-Mock -ParameterFilter { $ValidatedParameter -eq 'Not in Set' } -RemoveParameterType @('Path') -RemoveParameterValidation @('ValidatedParameter')
            Mock -CommandName Public-Module-Function -MockWith { Private-Module-Function $Path $ValidatedParameter } -Verifiable -ModuleName Module-To-Mock -ParameterFilter { $ValidatedParameter -eq 'Not in Set' } -RemoveParameterType @('Path') -RemoveParameterValidation @('ValidatedParameter')
            Public-Module-Function -Path 'C:\Temp\Public-Module-Function.txt' -ValidatedParameter 'Not in Set'
            Private-Module-Function -Path 'C:\Temp\Private-Module-Function.txt' -ValidatedParameter 'Not in Set'
            Should -Invoke Public-Module-Function -Exactly -Times 1
            Should -Invoke Private-Module-Function -Exactly -Times 2
        
            $DefinedVariable_In_It | Should -Be $null
            $Passed_Parameter | Should -Be '$DefinedVariable_In_It is available in the It block but not in the Mock block'
            # https://learn.microsoft.com/en-us/powershell/scripting/whats-new/differences-from-windows-powershell?view=powershell-7.4#allow-explicitly-specified-named-parameter-to-supersede-the-same-one-from-hashtable-splatting
            #! '-Parameters' '-ArgumentList' follow powershell splatting rules, unbounded parameters from '-Parameters' are appended to the end of the $ags list
            #! '-ArgumentList' can contain values that mimic this '-pattern:', be careful
            $args | Should -Be 'These are', 'available', 'in this block', '-Passed_Parameter:' , $Passed_Parameter
            # How to access '-ArgumentList' and '-Parameters' from inside the scriptblock?
            $PesterBoundParameters.Keys | Should -Be $null # $PesterBoundParameters is a mock variable, it's not available in the module scope
            $PSBoundParameters.Keys | Should -Be $null # $PSBoundParameters is a script scope variable, it's not available in Run phase
        }
    }

    It 'Invoke mock' {
        # Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-Invoke] [-CommandName <Object>] [-Times <Object>] [-ParameterFilter <Object>] [-ExclusiveFilter <Object>] [-ModuleName <Object>] [-Scope <Object>] [-Exactly] [-CallerSessionState <Object>] [<CommonParameters>]
        # https://pester.dev/docs/commands/Should#-invoke
        # Checks if a Mocked command has been called a certain number of times and throws an exception if it has not.
        Should -Not -Invoke Mock-Function

        Mock-Function
        Should -Invoke Mock-Function -Times 1
        Should -Not -Invoke Mock-Function -Exactly -Times 2
        Should -Invoke Mock-Function -Exactly -Times 1

        Mock-Function
        Should -Invoke Mock-Function -Times 1 # At least 1<=X times
        Should -Not -Invoke Mock-Function -Times 3 # At at most 2 times, !(3<=X) is 2<X
        Should -Invoke Mock-Function -Exactly -Times 2
    }

    It 'Invoke verifiable mock' {
        # https://pester.dev/docs/commands/Mock#-verifiable
        # When this is set, the mock will be checked when Should -InvokeVerifiable is called.
        
        # Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-InvokeVerifiable] [<CommonParameters>]
        # https://pester.dev/docs/commands/Should#-invokeverifiable
        # Checks if any Verifiable Mock has not been invoked. If so, this will throw an exception.


        Mock First-Function { 'Mock-First-Function called' } -Verifiable
        Mock Second-Function { 'Mock-Second-Function called' } -Verifiable

        First-Function
        # If we comment the call to Second-Function, the test will fail with the following error:
        #    Expected all verifiable mocks to be called, but these were not:
        #    Command Second-Function
        Second-Function
        Should -InvokeVerifiable       
    }

    Describe 'Invoke Inner Mock' {
        It 'Invoke Private-Module-Function' {
            Mock Private-Module-Function { 'Private-Module-Function' } -ModuleName Module-To-Mock
            Public-Module-Function
            Should -Invoke Private-Module-Function -Exactly -Times 1 -ModuleName Module-To-Mock
        }
    }

    It "Invoke mock with '-ParameterFilter'" {
        # Mock Set-Content -ParameterFilter { $Path }
        Mock-Function -Param 'C:\Temp\test.txt'
        Mock-Function -Param 'C:\Temp\test.txt'
        Mock-Function -Param 'D:\Temp\test.txt'
        Should -Invoke Mock-Function -Exactly -Times 2 -ParameterFilter { $Param -eq 'C:\Temp\test.txt' }
        Should -Invoke Mock-Function -Exactly -Times 3
    }
    It "Invoke moch with '-ExclusiveFilter'" {
        Mock-Function -Param 'C:\'
        # Mock-Function -Param 'C:\Temp'
        # Expected Mock-Function to only be called with with parameters matching the specified filter, but 1 non-matching calls were made
        Should -Invoke Mock-Function -ExclusiveFilter { $Param -eq 'C:\' }
    }
    Describe 'Mock override rules' {
        It "Mocks with the same '-ParameterFilter' override each other but don't affect other mocks" {
            Mock Public-Module-Function { 'no filter mocked' }
            Mock Public-Module-Function { 'filter 1 mocked' } -ParameterFilter { $Param -eq 'Filter 1' }
            Mock Public-Module-Function { 'filter 2 mocked' } -ParameterFilter { $Param -eq 'Filter 2' }
            Public-Module-Function | Should -Be 'no filter mocked'
            Public-Module-Function -Param 'Filter 1' | Should -Be 'filter 1 mocked'
            Public-Module-Function -Param 'Filter 2' | Should -Be 'filter 2 mocked'

            Mock Public-Module-Function { 'no filter overridden' }
            Mock Public-Module-Function { 'filter 1 overridden' } -ParameterFilter { $Param -eq 'Filter 1' }
            Mock Public-Module-Function { 'filter 2 overridden' } -ParameterFilter { $Param -eq 'Filter 2' }

            Public-Module-Function | Should -Be 'no filter overridden'
            Public-Module-Function -Param 'Filter 1' | Should -Be 'filter 1 overridden'
            Public-Module-Function -Param 'Filter 2' | Should -Be 'filter 2 overridden'
            Should -Invoke Public-Module-Function -Exactly -Times 6
        }
        Describe "There are no overrides behavior for '-RemoveParameterValidation' and '-RemoveParameterType', they're not affected by '-ParameterFilter'" {
            It "They don't work if mock was previously defined without them" {
                Mock Public-Module-Function { 'mocked' }
                Mock Public-Module-Function { 'no filter overridden' } -RemoveParameterValidation @('ValidatedParameter')
                { Public-Module-Function -ValidatedParameter 'Not in Set' } | Should -Throw -ExpectedMessage 'Cannot validate argument on parameter ''ValidatedParameter''. The argument "Not in Set" does not belong to the set "Value,Different Value" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again.'
                Public-Module-Function | Should -Be 'no filter overridden'
                Should -Invoke Public-Module-Function -Exactly -Times 1
      
                Mock Public-Module-Function { 'no filter overridden 2' } -RemoveParameterType @('Path')
                { Public-Module-Function (New-Object System.Object) } | Should -Throw -ExpectedMessage 'Cannot process argument transformation on parameter ''Path''. Cannot convert the "System.Object" value of type "System.Object" to type "System.IO.FileInfo".'
                Public-Module-Function | Should -Be 'no filter overridden 2'
                Should -Invoke Public-Module-Function -Exactly -Times 2

                Mock Public-Module-Function { 'filter 1 overridden' } -ParameterFilter { $Param -eq 'Filter 1' } -RemoveParameterValidation @('ValidatedParameter')
                { Public-Module-Function -ValidatedParameter 'Not in Set' -Param 'Filter 1' } | Should -Throw -ExpectedMessage 'Cannot validate argument on parameter ''ValidatedParameter''. The argument "Not in Set" does not belong to the set "Value,Different Value" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again.'
                Public-Module-Function | Should -Be 'no filter overridden 2'
                Public-Module-Function -Param 'Filter 1' | Should -Be 'filter 1 overridden'
                Should -Invoke Public-Module-Function -Exactly -Times 4

                Mock Public-Module-Function { 'filter 1 overridden 2' } -ParameterFilter { $Param -eq 'Filter 1' } -RemoveParameterType @('Path')
                { Public-Module-Function (New-Object System.Object) -Param 'Filter 1' } | Should -Throw -ExpectedMessage 'Cannot process argument transformation on parameter ''Path''. Cannot convert the "System.Object" value of type "System.Object" to type "System.IO.FileInfo".'
                Public-Module-Function | Should -Be 'no filter overridden 2'
                Public-Module-Function -Param 'Filter 1' | Should -Be 'filter 1 overridden 2'
                Should -Invoke Public-Module-Function -Exactly -Times 6
            }
            It 'The first mock affects all subsequently defined mocks and cannot be changed' {
                Mock Public-Module-Function { 'filter 1 mocked' } -ParameterFilter { $Param -eq 'Filter 1' } -RemoveParameterValidation @('ValidatedParameter') -RemoveParameterType @('Path')
                Mock Public-Module-Function { 'filter 2 mocked' } -ParameterFilter { $Param -eq 'Filter 2' }
                Mock Public-Module-Function { 'mocked' }
                
                # '-RemoveParameterValidation' check
                { Public-Module-Function -ValidatedParameter 'Not in Set' | Should -Be 'mocked' } | Should -Not -Throw
                { Public-Module-Function -ValidatedParameter 'Not in Set' -Param 'Filter 1' | Should -Be 'filter 1 mocked' } | Should -Not -Throw
                { Public-Module-Function -ValidatedParameter 'Not in Set' -Param 'Filter 2' | Should -Be 'filter 2 mocked' } | Should -Not -Throw
                # '-RemoveParameterType' check
                { Public-Module-Function (New-Object System.Object) | Should -Be 'mocked' } | Should -Not -Throw
                { Public-Module-Function (New-Object System.Object) -Param 'Filter 1' | Should -Be 'filter 1 mocked' } | Should -Not -Throw
                { Public-Module-Function (New-Object System.Object) -Param 'Filter 2' | Should -Be 'filter 2 mocked' } | Should -Not -Throw
                
                Mock Public-Module-Function { 'filter 1 mocked' } -ParameterFilter { $Param -eq 'Filter 1' } -RemoveParameterValidation @('AnotherValidatedParameter')
                Mock Public-Module-Function { 'filter 2 mocked' } -ParameterFilter { $Param -eq 'Filter 2' } -RemoveParameterValidation @('AnotherValidatedParameter')
                Mock Public-Module-Function { 'mocked' } -RemoveParameterValidation @('AnotherValidatedParameter')
                # '-RemoveParameterValidation' wasn't modified
                { Public-Module-Function -AnotherValidatedParameter 'Not in Set' } | Should -Throw
                { Public-Module-Function -AnotherValidatedParameter 'Not in Set' -Param 'Filter 1' } | Should -Throw
                { Public-Module-Function -AnotherValidatedParameter 'Not in Set' -Param 'Filter 2' } | Should -Throw
                # '-RemoveParameterValidation' recheck
                { Public-Module-Function -ValidatedParameter 'Not in Set' | Should -Be 'mocked' } | Should -Not -Throw
                { Public-Module-Function -ValidatedParameter 'Not in Set' -Param 'Filter 1' | Should -Be 'filter 1 mocked' } | Should -Not -Throw
                { Public-Module-Function -ValidatedParameter 'Not in Set' -Param 'Filter 2' | Should -Be 'filter 2 mocked' } | Should -Not -Throw
                # '-RemoveParameterType' recheck
                { Public-Module-Function (New-Object System.Object) | Should -Be 'mocked' } | Should -Not -Throw
                { Public-Module-Function (New-Object System.Object) -Param 'Filter 1' | Should -Be 'filter 1 mocked' } | Should -Not -Throw
                { Public-Module-Function (New-Object System.Object) -Param 'Filter 2' | Should -Be 'filter 2 mocked' } | Should -Not -Throw

                Should -Invoke Public-Module-Function -Exactly -Times 12
            }
            Describe 'InModuleScope block does not reset the above behavior' {
                It "They don't work if mock was previously defined without them" {
                    Mock Public-Module-Function { 'mocked' } -ModuleName Module-To-Mock
                    Mock Public-Module-Function { 'no filter overridden' } -RemoveParameterValidation @('ValidatedParameter') -ModuleName Module-To-Mock
                    InModuleScope -ModuleName Module-To-Mock {
                        { Public-Module-Function -ValidatedParameter 'Not in Set' } | Should -Throw -ExpectedMessage 'Cannot validate argument on parameter ''ValidatedParameter''. The argument "Not in Set" does not belong to the set "Value,Different Value" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again.'
                        Public-Module-Function | Should -Be 'no filter overridden'
                        Should -Invoke Public-Module-Function -Exactly -Times 1

                        Mock Public-Module-Function { 'mocked' } -ModuleName Module-To-Mock
                        Mock Public-Module-Function { 'no filter overridden' } -RemoveParameterValidation @('ValidatedParameter') -ModuleName Module-To-Mock
                        { Public-Module-Function -ValidatedParameter 'Not in Set' } | Should -Throw -ExpectedMessage 'Cannot validate argument on parameter ''ValidatedParameter''. The argument "Not in Set" does not belong to the set "Value,Different Value" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again.'
                        Public-Module-Function | Should -Be 'no filter overridden'
                        Should -Invoke Public-Module-Function -Exactly -Times 2
                    }
                }
                It 'The first mock affects all subsequently defined mocks and cannot be changed' {
                    Mock Public-Module-Function { 'filter 1 mocked' } -ParameterFilter { $Param -eq 'Filter 1' } -RemoveParameterValidation @('ValidatedParameter') -RemoveParameterType @('Path') -ModuleName Module-To-Mock
                    Mock Public-Module-Function { 'filter 2 mocked' } -ParameterFilter { $Param -eq 'Filter 2' } -ModuleName Module-To-Mock
                    Mock Public-Module-Function { 'mocked' } -ModuleName Module-To-Mock
                    InModuleScope -ModuleName Module-To-Mock {
                        # '-RemoveParameterValidation' check
                        { Public-Module-Function -ValidatedParameter 'Not in Set' | Should -Be 'mocked' } | Should -Not -Throw
                        { Public-Module-Function -ValidatedParameter 'Not in Set' -Param 'Filter 1' | Should -Be 'filter 1 mocked' } | Should -Not -Throw
                        { Public-Module-Function -ValidatedParameter 'Not in Set' -Param 'Filter 2' | Should -Be 'filter 2 mocked' } | Should -Not -Throw
                        # '-RemoveParameterType' check
                        { Public-Module-Function (New-Object System.Object) | Should -Be 'mocked' } | Should -Not -Throw
                        { Public-Module-Function (New-Object System.Object) -Param 'Filter 1' | Should -Be 'filter 1 mocked' } | Should -Not -Throw
                        { Public-Module-Function (New-Object System.Object) -Param 'Filter 2' | Should -Be 'filter 2 mocked' } | Should -Not -Throw
                    
                        Mock Public-Module-Function { 'filter 1 mocked' } -ParameterFilter { $Param -eq 'Filter 1' } -RemoveParameterValidation @('AnotherValidatedParameter')
                        Mock Public-Module-Function { 'filter 2 mocked' } -ParameterFilter { $Param -eq 'Filter 2' } -RemoveParameterValidation @('AnotherValidatedParameter')
                        Mock Public-Module-Function { 'mocked' } -RemoveParameterValidation @('AnotherValidatedParameter')
                        # '-RemoveParameterValidation' wasn't modified
                        { Public-Module-Function -AnotherValidatedParameter 'Not in Set' } | Should -Throw
                        { Public-Module-Function -AnotherValidatedParameter 'Not in Set' -Param 'Filter 1' } | Should -Throw
                        { Public-Module-Function -AnotherValidatedParameter 'Not in Set' -Param 'Filter 2' } | Should -Throw
                        # '-RemoveParameterValidation' recheck
                        { Public-Module-Function -ValidatedParameter 'Not in Set' | Should -Be 'mocked' } | Should -Not -Throw
                        { Public-Module-Function -ValidatedParameter 'Not in Set' -Param 'Filter 1' | Should -Be 'filter 1 mocked' } | Should -Not -Throw
                        { Public-Module-Function -ValidatedParameter 'Not in Set' -Param 'Filter 2' | Should -Be 'filter 2 mocked' } | Should -Not -Throw
                        # '-RemoveParameterType' recheck
                        { Public-Module-Function (New-Object System.Object) | Should -Be 'mocked' } | Should -Not -Throw
                        { Public-Module-Function (New-Object System.Object) -Param 'Filter 1' | Should -Be 'filter 1 mocked' } | Should -Not -Throw
                        { Public-Module-Function (New-Object System.Object) -Param 'Filter 2' | Should -Be 'filter 2 mocked' } | Should -Not -Throw
    
                        Should -Invoke Public-Module-Function -Exactly -Times 12
                    }
                }
            }
        }
        It 'basic function mock' {
            Mock Public-Module-Function { 'mocked' }
            Public-Module-Function | Should -Be 'mocked'
            Should -Invoke Public-Module-Function -Exactly -Times 1
        }
        It 'basic function mock in module scope' {
            InModuleScope Module-To-Mock {
                Mock Public-Module-Function { 'mocked' }
                Public-Module-Function | Should -Be 'mocked'
                # Check inside the InModuleScope block
                Should -Invoke Public-Module-Function -Exactly -Times 1 
            }
            # Check outside the InModuleScope block
            Should -Invoke Public-Module-Function -Exactly -Times 1 -ModuleName Module-To-Mock
        }
        It 'define mock outside of InModuleScope block and invoke inside' {
            Mock Public-Module-Function { 'mocked' } -ModuleName Module-To-Mock
            # execute the mock outside of the Module-To-Mock scope doesn't call the mock
            Public-Module-Function | Should -Not -Be 'mocked'
            InModuleScope Module-To-Mock {
                Public-Module-Function | Should -Be 'mocked'
                # Check inside the InModuleScope block
                Should -Invoke Public-Module-Function -Exactly -Times 1
            }
            # Check outside the InModuleScope block
            Should -Invoke Public-Module-Function -Exactly -Times 1 -ModuleName Module-To-Mock
        }
        It 'define mock for a private module function' {
            Mock Private-Module-Function { 'mocked' } -ModuleName Module-To-Mock
            # Public-Module-Function calls Private-Module-Function internally
            Public-Module-Function | Should -Be 'Public-Module-Function: mocked'
            Should -Invoke Private-Module-Function -Exactly -Times 1 -ModuleName Module-To-Mock
            InModuleScope Module-To-Mock {
                Should -Invoke Private-Module-Function -Exactly -Times 1
                Private-Module-Function | Should -Be 'mocked'
                Should -Invoke Private-Module-Function -Exactly -Times 2
            }
            # Check outside the InModuleScope block
            Should -Invoke Private-Module-Function -Exactly -Times 2 -ModuleName Module-To-Mock
        }
        
        It "'-ModuleName' mocks scope is InModuleScope block" {
            Mock Public-Module-Function { 'mocked' }
            Public-Module-Function | Should -Be 'mocked'
            Should -Invoke Public-Module-Function -Exactly -Times 1
            
            #! Without the '-ModuleName Module-To-Mock' invoking 'Public-Module-Function' inside InModuleScope will throw an error
            #* The following line could be inside InModuleScope block in which case it would work without '-ModuleName Module-To-Mock'
            Mock Public-Module-Function { 'module-name' } -ModuleName Module-To-Mock
            Public-Module-Function | Should -Be 'mocked'
            Should -Invoke Public-Module-Function -Exactly -Times 2
            Should -Invoke Public-Module-Function -Exactly -Times 0 -ModuleName Module-To-Mock
            
            Mock Private-Module-Function { 'private-module-name' } -ModuleName Module-To-Mock
            Should -Invoke Private-Module-Function -Exactly -Times 0 -ModuleName Module-To-Mock
            
            # Cannot define an in-module mock that calls a private function from the module outside of an InModuleScope block
            # Mock Public-Module-Function { Private-Module-Function } -ModuleName Module-To-Mock
            # CommandNotFoundException: The term 'Private-Module-Function' is not recognized as a name of a cmdlet, function, script file, or executable program.
            { Private-Module-Function } | Should -Throw -ExpectedMessage 'The term ''Private-Module-Function'' is not recognized as a name of a cmdlet, function, script file, or executable program.*'
            Should -Invoke Private-Module-Function -Exactly -Times 0 -ModuleName Module-To-Mock
            $ModuleVariable | Should -Be $null

            InModuleScope -ModuleName Module-To-Mock -ScriptBlock {
                $ModuleVariable | Should -Be 'ModuleVariable'

                # Inside a InModuleScope block -ModuleName is not required for Mock
                Should -Invoke Public-Module-Function -Exactly -Times 0 # -ModuleName Module-To-Mock
                Should -Invoke Private-Module-Function -Exactly -Times 0 # -ModuleName Module-To-Mock

                # Inside the InModuleScope block it execues the '-ModuleName' mock
                Public-Module-Function | Should -Be 'module-name'
                Should -Invoke Public-Module-Function -Exactly -Times 1 # -ModuleName Module-To-Mock
                Should -Invoke Private-Module-Function -Exactly -Times 0 # -ModuleName Module-To-Mock

                Mock Public-Module-Function { 'override' } # -ModuleName Module-To-Mock
                Public-Module-Function | Should -Be 'override'
                Private-Module-Function | Should -Be 'private-module-name'
                Should -Invoke Public-Module-Function -Exactly -Times 2 # -ModuleName Module-To-Mock
                Should -Invoke Private-Module-Function -Exactly -Times 1 # -ModuleName Module-To-Mock

                Mock Public-Module-Function { Private-Module-Function } # -ModuleName Module-To-Mock
                Public-Module-Function | Should -Be 'private-module-name'
                Should -Invoke Public-Module-Function -Exactly -Times 3 # -ModuleName Module-To-Mock
                Should -Invoke Private-Module-Function -Exactly -Times 2 # -ModuleName Module-To-Mock
            }
            # Outside the InModuleScope block the previous scope is restored, the '-ModuleName' invokes are kept
            Public-Module-Function | Should -Be 'mocked'
            Should -Invoke Public-Module-Function -Exactly -Times 3
            Should -Invoke Public-Module-Function -Exactly -Times 3 -ModuleName Module-To-Mock
            Should -Invoke Private-Module-Function -Exactly -Times 2 -ModuleName Module-To-Mock
        }
     
    }


    # https://pester.dev/docs/usage/mocking#counting-mocks-depends-on-placement
    # It, BeforeEach and AfterEach it defaults to It scope
    # In Describe, Context, BeforeAll and AfterAll, it default to Describe or Context based on the command that contains them.
    # Since Describe and Context cannot be nested in It blocks and BeforeAll, AfterAll do not execute when nested in It blocks stating explicitly '-Scope It' is redundant.
    Context 'Context wrapper for mocking' {
        BeforeAll {
            Should -Invoke Mock-Function -Exactly -Times 0 # Context scope
            Should -Invoke Mock-Function -Times 2 -Scope Describe # Describe scope, previous tests in outer describe also count
        }
        BeforeEach {
            Should -Invoke Mock-Function -Exactly -Times 0 # It scope
        }
        AfterEach {
            Should -Invoke Mock-Function -Exactly -Times 1 # It scope
        }
        AfterAll {
            Should -Invoke Mock-Function -Exactly -Times 3 # Context scope
            Should -Invoke Mock-Function -Times 5 -Scope Describe # Describe scope, previous tests in outer describe also count
        }
        It 'nested Context level mock' {
            Mock-Function
            Should -Invoke Mock-Function -Exactly -Times 1 # It scope
            Should -Invoke Mock-Function -Exactly -Times 1 -Scope Context # Context scope
            Should -Invoke Mock-Function -Times 2 -Scope Describe # Describe scope, previous tests in outer describe also count
        }
        Describe 'inner describe' {
            It 'nested Describe level mock' {
                Mock-Function
                Should -Invoke Mock-Function -Exactly -Times 1 # It scope
                Should -Invoke Mock-Function -Exactly -Times 2 -Scope Context # Context scope, previous tests in outer context also count
                Should -Invoke Mock-Function -Exactly -Times 1 -Scope Describe # Describe scope, wrapping with Describe resets the count
            }
        }
        Context 'inner context' {
            It 'nested Context level mock' {
                Mock-Function
                Should -Invoke Mock-Function -Exactly -Times 1 # It scope
                Should -Invoke Mock-Function -Exactly -Times 1 -Scope Context # Context scope, wrapping with Context resets the count
                Should -Invoke Mock-Function -Times 2 -Scope Describe # Describe scope, previous tests in outer describe also count
            }
        }
    }
    Describe 'Describe wrapper for mocking' {
        BeforeAll {
            Should -Invoke Mock-Function -Exactly -Times 0 # Describe scope, wrapping with Describe resets the count
        }
        BeforeEach {
            Should -Invoke Mock-Function -Exactly -Times 0 # It scope
        }
        AfterEach {
            Should -Invoke Mock-Function -Exactly -Times 1 # It scope
        }
        AfterAll {
            Should -Invoke Mock-Function -Exactly -Times 3 # Describe scope, wrapping with Describe resets the count
        }
        It 'nested Context level mock' {
            Mock-Function
            Should -Invoke Mock-Function -Exactly -Times 1 # It scope
            # Should -Invoke Mock-Function -Exactly -Times 1 -Scope Context # Context scope
            #    RuntimeException: Assertion is not placed directly nor nested inside a Context block, but -Scope Context is specified.
            Should -Invoke Mock-Function -Exactly -Times 1 -Scope Describe # Describe scope, wrapping with Describe resets the count
        }
        Describe 'inner describe' {
            It 'nested Describe level mock' {
                Mock-Function
                Should -Invoke Mock-Function -Exactly -Times 1 # It scope
                # Should -Invoke Mock-Function -Exactly -Times 1 -Scope Context # Context scope, previous tests in outer context also count
                #    RuntimeException: Assertion is not placed directly nor nested inside a Context block, but -Scope Context is specified.

                Should -Invoke Mock-Function -Exactly -Times 1 -Scope Describe # Describe scope, wrapping with Describe resets the count
            }
        }
        Context 'inner context' {
            It 'nested Context level mock' {
                Mock-Function
                Should -Invoke Mock-Function -Exactly -Times 1 # It scope
                Should -Invoke Mock-Function -Exactly -Times 1 -Scope Context # Context scope
                Should -Invoke Mock-Function -Exactly -Times 3 -Scope Describe # Describe scope, previous tests in outer describe also count
            }
        } 

    }
}