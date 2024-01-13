# Get-ShouldOperator 

# Name                             Alias
# ----                             -----
# Be                               EQ
# BeExactly                        CEQ
# BeGreaterThan                    GT
# BeLessOrEqual                    LE
# BeIn
# BeLessThan                       LT
# BeGreaterOrEqual                 GE
# BeLike
# BeLikeExactly
# BeNullOrEmpty
# BeOfType                         HaveType
# BeTrue
# BeFalse
# Contain
# Exist
# FileContentMatch
# FileContentMatchExactly
# FileContentMatchMultiline
# FileContentMatchMultilineExactly
# HaveCount
# HaveParameter
# Match
# MatchExactly                     CMATCH
# Throw
# InvokeVerifiable
# Invoke
# [psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators")::get

Describe 'Should examples' {
    Describe 'BeTrue and BeFalse' {
        #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-BeTrue] [<CommonParameters>]
        # Asserts that the value is true, or truthy.
        #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-BeFalse] [<CommonParameters>]
        # Asserts that the value is false, or falsy.
        It 'Piped syntax' {
            $true | Should -BeTrue
            $false | Should -BeFalse
            $null | Should -BeFalse
            @() | Should -BeFalse
            @{} | Should -BeTrue
            [PSCustomObject]@{} | Should -BeTrue

            1 | Should -BeTrue
            0 | Should -BeFalse
            2 | Should -BeTrue
            'Hello World' | Should -BeTrue
            '' | Should -BeFalse
        }
        It 'Direct syntax' {
            Should -ActualValue $true -BeTrue
            Should -ActualValue $false -BeFalse
            Should -ActualValue $null -BeFalse
            Should -ActualValue @() -BeFalse
            Should -ActualValue @{} -BeTrue
            Should -ActualValue [PSCustomObject]@ {} -BeTrue

            Should -ActualValue 1 -BeTrue
            Should -ActualValue 0 -BeFalse
            Should -ActualValue 2 -BeTrue
            Should -ActualValue 'Hello World' -BeTrue
            Should -ActualValue '' -BeFalse
        }
        It 'Arrays are evaluated element by element when piped' {
            { @($true, $false) | Should -BeTrue } | Should -Throw -ExpectedMessage '*Expected $true, but got $false.*'
            { @($true, '') | Should -BeTrue } | Should -Throw -ExpectedMessage '*Expected $true, but got <empty>.*'
            { @($true, 0) | Should -BeTrue } | Should -Throw -ExpectedMessage '*Expected $true, but got 0.*'
        }
        It 'Arrays are evaluated as a whole when not piped' {
            # https://stackoverflow.com/a/46592939/12603110
            Should -ActualValue @($true, $false, $null, @(), @{}, [PSCustomObject]@{}, 1, 0, 2, 'Hello World', '') -BeTrue
        }
        It "Omitting '-ActualValue' inputs `$null to the Should command" {
            { Should $true -BeTrue } | Should -Throw -ExpectedMessage '*Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5.*'
            { Should @($true) -BeTrue } | Should -Throw -ExpectedMessage '*Expected $true, because True, but got $null.*'
        }
    }
    Describe 'BeNullOrEmpty' {
        #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-BeNullOrEmpty] [<CommonParameters>]
        # Checks values for null or empty (strings). The static [String]::IsNullOrEmpty() method is used to do the comparison.
        It 'Piped syntax' {
            $null | Should -BeNullOrEmpty
            @() | Should -BeNullOrEmpty
            '' | Should -BeNullOrEmpty
            ' ' | Should -Not -BeNullOrEmpty
            'Hello World' | Should -Not -BeNullOrEmpty
        }
        It 'Direct syntax' {
            Should -ActualValue $null -BeNullOrEmpty
            Should -ActualValue @() -BeNullOrEmpty
            Should -ActualValue '' -BeNullOrEmpty
            Should -ActualValue ' ' -Not -BeNullOrEmpty
            Should -ActualValue 'Hello World' -Not -BeNullOrEmpty
        }
        It 'Single element arrays are evaluated as the single element' {
            { Should -ActualValue @(1) -BeNullOrEmpty } | Should -Throw -ExpectedMessage '*Expected $null or empty, but got 1.*'
            { @(1) | Should -BeNullOrEmpty } | Should -Throw -ExpectedMessage '*Expected $null or empty, but got 1.*'
            
            Should -ActualValue @('') -BeNullOrEmpty
            @('') | Should -BeNullOrEmpty
            Should -ActualValue @($null) -BeNullOrEmpty
            @($null) | Should -BeNullOrEmpty
        }
        It 'Array with 2 or more elements are evaluated as a whole when piped' {
            { @($null, $null) | Should -BeNullOrEmpty } | Should -Throw -ExpectedMessage '*Expected $null or empty, but got @($null, $null).*'
            { @('', '') | Should -BeNullOrEmpty } | Should -Throw -ExpectedMessage '*Expected $null or empty, but got @(<empty>, <empty>).*'
            { @(1, 2) | Should -BeNullOrEmpty } | Should -Throw -ExpectedMessage '*Expected $null or empty, but got @(1, 2).*'
        }
        It "Omitting '-ActualValue' inputs `$null to the Should command" {
            { Should 'Hello World' -BeNullOrEmpty } | Should -Throw -ExpectedMessage '*Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5.*'
            Should @('Hello World') -BeNullOrEmpty
        }
    }
    Describe 'Be and BeExactly' {
        #? Should [[-ActualValue] <Object>] [-Be] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [<CommonParameters>]
        # Compares one object with another for equality and throws if the two objects are not the same. This comparison is case insensitive.
        #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-BeExactly] [<CommonParameters>]
        # Compares one object with another for equality and throws if the two objects are not the same. This comparison is case sensitive.
        It 'Piped syntax' {
            1 | Should -Be 1
            $true | Should -Be $true
            1 | Should -Be $true
            $true | Should -Be 1

            0 | Should -Be 0
            $false | Should -Be $false
            0 | Should -Be $false
            $false | Should -Be 0

            2 | Should -Be 2
            2 | Should -Be $true
            $true | Should -Not -Be 2

            @(1, 2, 3) | Should -Be @(1, 2, 3)
            @(1, 2, 3) | Should -Be @('1', '2', '3')
            @('1', '2', '3') | Should -Be @(1, 2, 3)

            'Hello World' | Should -Be 'Hello World'
            'Hello World' | Should -Be 'hello world'
            'Hello World' | Should -BeExactly 'Hello World'
            'Hello World' | Should -Not -BeExactly 'hello world'

            @('Hello World') | Should -Be 'Hello World'
            @('Hello World') | Should -Be 'hello world'
            @('Hello World') | Should -BeExactly 'Hello World'
            @('Hello World') | Should -Not -BeExactly 'hello world'
            
            @('one', 'two', 'three') | Should -Be @('One', 'Two', 'Three')
            @('one', 'two', 'three') | Should -BeExactly @('one', 'two', 'three')
            @('one', 'two', 'three') | Should -Not -BeExactly @('One', 'Two', 'Three')

            @(@(1, 2, 3), @(4, 5, 6)) | Should -Be @(@(1, 2, 3), @(4, 5, 6))
            @(@('one', 'two', 'three'), @('four', 'five', 'six')) | Should -Be @(@('One', 'Two', 'Three'), @('Four', 'Five', 'Six'))

            ([Guid]'00000000-0000-0000-0000-000000000000') | Should -Be ([Guid]'00000000-0000-0000-0000-000000000000')

            ([TimeSpan]::FromDays(1)) | Should -Be ([TimeSpan]::FromDays(1))

            ([Version]'1.2.3') | Should -Be ([Version]'1.2.3')
        }
        It 'Direct syntax' {
            Should -ActualValue 1 -Be 1
            Should -ActualValue $true -Be $true
            Should -ActualValue 1 -Be $true
            Should -ActualValue $true -Be 1
            
            Should -ActualValue 0 -Be 0
            Should -ActualValue $false -Be $false
            Should -ActualValue 0 -Be $false
            Should -ActualValue $false -Be 0

            Should -ActualValue 2 -Be 2
            Should -ActualValue 2 -Be $true
            Should -ActualValue $true -Not -Be 2

            { Should -ActualValue @(1, 2, 3) -Be @(1, 2, 3) } | Should -Throw -ExpectedMessage '*Expected @(1, 2, 3), but got @(1, 2, 3).*'

            Should -ActualValue 'Hello World' -Be 'Hello World'
            Should -ActualValue 'Hello World' -Be 'hello world'
            Should -ActualValue 'Hello World' -BeExactly 'Hello World'
            Should -ActualValue 'Hello World' -Not -BeExactly 'hello world'

            { Should -ActualValue @('one', 'two', 'three') -Be @('One', 'Two', 'Three') } | Should -Throw -ExpectedMessage "*Expected @('One', 'Two', 'Three'), but got @('one', 'two', 'three').*"
            { Should -ActualValue @('one', 'two', 'three') -BeExactly @('one', 'two', 'three') } | Should -Throw -ExpectedMessage "*Expected exactly @('one', 'two', 'three'), but got @('one', 'two', 'three').*"
            Should -ActualValue @('one', 'two', 'three') -Not -BeExactly @('One', 'Two', 'Three') # This evaluates to true because the arrays are not the same object.

            { Should -ActualValue @(@(1, 2, 3), @(4, 5, 6)) -Be @(@(1, 2, 3), @(4, 5, 6)) } | Should -Throw -ExpectedMessage '*Expected @(@(1, 2, 3), @(4, 5, 6)), but got @(@(1, 2, 3), @(4, 5, 6)).*'
            { Should -ActualValue @(@('one', 'two', 'three'), @('four', 'five', 'six')) -Be @(@('One', 'Two', 'Three'), @('Four', 'Five', 'Six')) } | Should -Throw -ExpectedMessage "*Expected @(@('One', 'Two', 'Three'), @('Four', 'Five', 'Six')), but got @(@('one', 'two', 'three'), @('four', 'five', 'six')).*"

            Should -ActualValue ([Guid]'00000000-0000-0000-0000-000000000000') -Be ([Guid]'00000000-0000-0000-0000-000000000000')

            Should -ActualValue ([TimeSpan]::FromDays(1)) -Be ([TimeSpan]::FromDays(1))

            Should -ActualValue ([Version]'1.2.3') -Be ([Version]'1.2.3')
        }
        It 'Instances are not equivalent' {
            { @{} | Should -Be @{} } | Should -Throw -ExpectedMessage '*Expected System.Collections.Hashtable, but got System.Collections.Hashtable.*'
            { @{Name = 'John'; Age = 30 } | Should -Be @{Name = 'John'; Age = 30 } } | Should -Throw -ExpectedMessage '*Expected System.Collections.Hashtable, but got System.Collections.Hashtable.*'
            { [pscustomobject]@{} | Should -Be ([pscustomobject]@{}) } | Should -Throw -ExpectedMessage '*Expected , but got .*'
            { [pscustomobject]@{Name = 'John'; Age = 30 } | Should -Be ([pscustomobject]@{Name = 'John'; Age = 30 }) } | Should -Throw -ExpectedMessage '*Expected @{Name=John; Age=30}, but got @{Name=John; Age=30}.*'
        }
        It 'Empty array, `$null and @(`$null) are equivalent when piped' {
            @() | Should -Be @()
            @($null) | Should -Be @()
            $null | Should -Be @()

            @() | Should -Be $null
            @($null) | Should -Be $null
            $null | Should -Be $null

            @() | Should -Be @($null)
            @($null) | Should -Be @($null)
            $null | Should -Be @($null)
            
            { Should -ActualValue @() -Be @() } | Should -Throw -ExpectedMessage '*Expected $null, but got @().*'
            { Should -ActualValue @($null) -Be -ExpectedValue @() } | Should -Throw -ExpectedMessage '*Expected $null, but got @($null).*'
            Should -ActualValue $null -Be -ExpectedValue @()

            { Should -ActualValue @() -Be -ExpectedValue $null } | Should -Throw -ExpectedMessage '*Expected $null, but got @().*'
            { Should -ActualValue @($null) -Be -ExpectedValue $null } | Should -Throw -ExpectedMessage '*Expected $null, but got @($null).*'
            Should -ActualValue $null -Be -ExpectedValue $null

            { Should -ActualValue @() -Be -ExpectedValue @($null) } | Should -Throw -ExpectedMessage '*Expected $null, but got @().*'
            { Should -ActualValue @($null) -Be -ExpectedValue @($null) } | Should -Throw -ExpectedMessage '*Expected $null, but got @($null).*'
            Should -ActualValue $null -Be -ExpectedValue @($null)
        }
        It 'Single element arrays are evaluated as the single element' {
            @(1) | Should -Be 1
            @(1) | Should -Be @(1)
            @(1) | Should -Be '1'
            @(1) | Should -Be @('1')

            Should -ActualValue @(1) -Be 1
            Should -ActualValue @(1) -Be @(1)
            Should -ActualValue @(1) -Be '1'
            Should -ActualValue @(1) -Be @('1')
        }
        It 'Array with 2 or more elements are evaluated as a whole when piped' {
            { @(1, 2, 3) | Should -Be 1 } | Should -Throw -ExpectedMessage '*Expected 1, but got @(1, 2, 3).*'
            { @(1, 2, 3) | Should -BeExactly 1 } | Should -Throw -ExpectedMessage '*Expected exactly 1, but got @(1, 2, 3).*'
            @(1, 2, 3) | Should -Be @(1, 2, 3)
            @(1, 2, 3) | Should -BeExactly @(1, 2, 3)
        }
        It "Omitting '-ActualValue' inputs `$null to the Should command and defaults to '-ExpectedValue'" {
            { Should 'Hello World' -Be $null } | Should -Throw -ExpectedMessage '*Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5.*'
            { Should @('Hello World') -Be $null } | Should -Throw -ExpectedMessage "*Expected 'Hello World', but got `$null."
            { Should @('Hello') -Be 'World' } | Should -Throw -ExpectedMessage "*Expected 'Hello', because World, but got `$null.*"
        }
    }
    Describe 'BeGreaterThan, BeGreaterOrEqual and BeLessThan, BeLessOrEqual' {
        #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-BeGreaterThan] [<CommonParameters>]
        # Asserts that the value is greater than the expected value.
        #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-BeGreaterOrEqual] [<CommonParameters>]
        # Asserts that a number (or other comparable value) is greater than or equal to an expected value. Uses PowerShell"s -ge operator to compare the two values.
        #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-BeLessThan] [<CommonParameters>]
        # Asserts that the value is less than the expected value.
        #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-BeLessOrEqual] [<CommonParameters>]
        # Asserts that a number (or other comparable value) is lower than, or equal to an expected value. Uses PowerShell"s -le operator to compare the two values.

        It 'Piped syntax' {
            1GB | Should -BeGreaterThan 1MB
            1MB | Should -BeLessThan 1GB

            3.1416 | Should -BeGreaterThan 3.14
            3.14 | Should -BeLessThan 3.1416

            2 | Should -BeGreaterThan 1
            1 | Should -BeLessThan 2

            'DEF' | Should -BeGreaterThan 'abc'
            'DEF' | Should -BeGreaterThan 'ABC'
            'def' | Should -BeGreaterThan 'abc'
            'def' | Should -BeGreaterThan 'ABC'
            { 'ABC' | Should -BeGreaterThan 'abc' } | Should -Throw -ExpectedMessage "*Expected the actual value to be greater than 'abc', but got 'ABC'.*"
            { 'abc' | Should -BeGreaterThan 'ABC' } | Should -Throw -ExpectedMessage "*Expected the actual value to be greater than 'ABC', but got 'abc'.*"
            'abc' | Should -BeGreaterOrEqual 'ABC'
            'ABC' | Should -BeGreaterOrEqual 'abc'
            'abc' | Should -BeLessThan 'DEF'
            'ABC' | Should -BeLessThan 'DEF'
            'abc' | Should -BeLessThan 'def'
            'ABC' | Should -BeLessThan 'def'
            { 'abc' | Should -BeLessThan 'ABC' } | Should -Throw -ExpectedMessage "*Expected the actual value to be less than 'ABC', but got 'abc'.*"
            { 'ABC' | Should -BeLessThan 'abc' } | Should -Throw -ExpectedMessage "*Expected the actual value to be less than 'abc', but got 'ABC'.*"
            'ABC' | Should -BeLessOrEqual 'abc'
            'abc' | Should -BeLessOrEqual 'ABC'

            (Get-Date) | Should -BeGreaterThan (Get-Date).AddDays(-1)
            (Get-Date).AddDays(-1) | Should -BeLessThan (Get-Date)
            (Get-Date -Year 2022 -Month 1 -Day 2) | Should -BeGreaterThan (Get-Date -Year 2022 -Month 1 -Day 1)
            (Get-Date -Year 2022 -Month 1 -Day 1) | Should -BeLessThan (Get-Date -Year 2022 -Month 1 -Day 2)
            
            { (Get-Date -Year 2022 -Month 1 -Day 1) | Should -BeGreaterThan (Get-Date -Year 2022 -Month 1 -Day 1) } | Should -Throw -ExpectedMessage '*Expected the actual value to be greater than *, but got *.*'
            { (Get-Date -Year 2022 -Month 1 -Day 1) | Should -BeGreaterOrEqual (Get-Date -Year 2022 -Month 1 -Day 1) } | Should -Throw -ExpectedMessage '*Expected the actual value to be greater than *, but got *.*'
            (Get-Date -Year 2022 -Month 1 -Day 1) | Should -BeLessThan (Get-Date -Year 2022 -Month 1 -Day 1)
            (Get-Date -Year 2022 -Month 1 -Day 1) | Should -BeLessOrEqual (Get-Date -Year 2022 -Month 1 -Day 1)

            ([Guid]'00000000-0000-0000-0000-000000000001') | Should -BeGreaterThan ([Guid]'00000000-0000-0000-0000-000000000000')
            ([Guid]'00000000-0000-0000-0000-000000000000') | Should -BeLessThan ([Guid]'00000000-0000-0000-0000-000000000001')

            ([TimeSpan]::FromDays(2)) | Should -BeGreaterThan ([TimeSpan]::FromDays(1))
            ([TimeSpan]::FromDays(1)) | Should -BeLessThan ([TimeSpan]::FromDays(2))

            [Version]'1.2.4' | Should -BeGreaterThan ([Version]'1.2.3')
            [Version]'1.2.3' | Should -BeLessThan ([Version]'1.2.4')
        }
        It 'Direct syntax' {
            Should -ActualValue 1GB -BeGreaterThan 1MB
            Should -ActualValue 1MB -BeLessThan 1GB

            Should -ActualValue 3.1416 -BeGreaterThan 3.14
            Should -ActualValue 3.14 -BeLessThan 3.1416

            Should -ActualValue 2 -BeGreaterThan 1
            Should -ActualValue 1 -BeLessThan 2

            Should -ActualValue 'DEF' -BeGreaterThan 'abc'
            Should -ActualValue 'DEF' -BeGreaterThan 'ABC'
            Should -ActualValue 'def' -BeGreaterThan 'abc'
            Should -ActualValue 'def' -BeGreaterThan 'ABC'
            { Should -ActualValue 'ABC' -BeGreaterThan 'abc' } | Should -Throw -ExpectedMessage "*Expected the actual value to be greater than 'abc', but got 'ABC'.*"
            { Should -ActualValue 'abc' -BeGreaterThan 'ABC' } | Should -Throw -ExpectedMessage "*Expected the actual value to be greater than 'ABC', but got 'abc'.*"
            Should -ActualValue 'abc' -BeGreaterOrEqual 'ABC'
            Should -ActualValue 'ABC' -BeGreaterOrEqual 'abc'
            Should -ActualValue 'abc' -BeLessThan 'DEF'
            Should -ActualValue 'ABC' -BeLessThan 'DEF'
            Should -ActualValue 'abc' -BeLessThan 'def'
            Should -ActualValue 'ABC' -BeLessThan 'def'
            { Should -ActualValue 'abc' -BeLessThan 'ABC' } | Should -Throw -ExpectedMessage "*Expected the actual value to be less than 'ABC', but got 'abc'.*"
            { Should -ActualValue 'ABC' -BeLessThan 'abc' } | Should -Throw -ExpectedMessage "*Expected the actual value to be less than 'abc', but got 'ABC'.*"
            Should -ActualValue 'ABC' -BeLessOrEqual 'abc'
            Should -ActualValue 'abc' -BeLessOrEqual 'ABC'

            Should -ActualValue (Get-Date) -BeGreaterThan (Get-Date).AddDays(-1)
            Should -ActualValue (Get-Date).AddDays(-1) -BeLessThan (Get-Date)
            Should -ActualValue (Get-Date -Year 2022 -Month 1 -Day 2) -BeGreaterThan (Get-Date -Year 2022 -Month 1 -Day 1)

            { Should -ActualValue (Get-Date -Year 2022 -Month 1 -Day 1) -BeGreaterThan (Get-Date -Year 2022 -Month 1 -Day 1) } | Should -Throw -ExpectedMessage '*Expected the actual value to be greater than *, but got *.*'
            { Should -ActualValue (Get-Date -Year 2022 -Month 1 -Day 1) -BeGreaterOrEqual (Get-Date -Year 2022 -Month 1 -Day 1) } | Should -Throw -ExpectedMessage '*Expected the actual value to be greater than *, but got *.*'
            Should -ActualValue (Get-Date -Year 2022 -Month 1 -Day 1) -BeLessThan (Get-Date -Year 2022 -Month 1 -Day 2)
            Should -ActualValue (Get-Date -Year 2022 -Month 1 -Day 1) -BeLessOrEqual (Get-Date -Year 2022 -Month 1 -Day 2)

            Should -ActualValue ([Guid]'00000000-0000-0000-0000-000000000001') -BeGreaterThan ([Guid]'00000000-0000-0000-0000-000000000000')
            Should -ActualValue ([Guid]'00000000-0000-0000-0000-000000000000') -BeLessThan ([Guid]'00000000-0000-0000-0000-000000000001')

            Should -ActualValue ([TimeSpan]::FromDays(2)) -BeGreaterThan ([TimeSpan]::FromDays(1))
            Should -ActualValue ([TimeSpan]::FromDays(1)) -BeLessThan ([TimeSpan]::FromDays(2))

            Should -ActualValue ([Version]'1.2.4') -BeGreaterThan ([Version]'1.2.3')
            Should -ActualValue ([Version]'1.2.3') -BeLessThan ([Version]'1.2.4')
        }
        It 'Single element arrays are evaluated as the single element' {
            @(1) | Should -BeGreaterThan 0
            @(1) | Should -BeGreaterOrEqual 1
            @(1) | Should -BeLessThan 2
            @(1) | Should -BeLessOrEqual 1

            Should -ActualValue @(1) -BeGreaterThan 0
            Should -ActualValue @(1) -BeGreaterOrEqual 1
            Should -ActualValue @(1) -BeLessThan 2
            Should -ActualValue @(1) -BeLessOrEqual 1
        }
        It 'Arrays are evaluated element by element when piped' {
            { @(1, 2, 3) | Should -BeGreaterThan 2 } | Should -Throw -ExpectedMessage '*Expected the actual value to be greater than 2, but got 1.*'
            { @(1, 2, 3) | Should -BeGreaterOrEqual 2 } | Should -Throw -ExpectedMessage '*Expected the actual value to be greater than or equal to 2, but got 1.*'
            { @(1, 2, 3) | Should -BeLessThan 2 } | Should -Throw -ExpectedMessage '*Expected the actual value to be less than 2, but got 2.*'
            { @(1, 2, 3) | Should -BeLessOrEqual 2 } | Should -Throw -ExpectedMessage '*Expected the actual value to be less than or equal to 2, but got 3.*'
        }
        It 'Arrays are evaluated as a whole when not piped' {
            { Should -ActualValue @(1, 2, 3) -BeGreaterThan 2 } | Should -Throw -ExpectedMessage '*Expected the actual value to be greater than 2, but got @(1, 2, 3).*'
            { Should -ActualValue @(1, 2, 3) -BeGreaterOrEqual 2 } | Should -Throw -ExpectedMessage '*Expected the actual value to be greater than or equal to 2, but got @(1, 2, 3).*'
            { Should -ActualValue @(1, 2, 3) -BeLessThan 2 } | Should -Throw -ExpectedMessage '*Expected the actual value to be less than 2, but got @(1, 2, 3).*'
            { Should -ActualValue @(1, 2, 3) -BeLessOrEqual 2 } | Should -Throw -ExpectedMessage '*Expected the actual value to be less than or equal to 2, but got @(1, 2, 3).*'
        }
        It "Omitting '-ActualValue' inputs `$null to the Should command and defaults to '-ExpectedValue'" {
            { Should 1 -BeGreaterThan $null } | Should -Throw -ExpectedMessage '*Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5.*'
            { Should @(1) -BeGreaterThan $null } | Should -Throw -ExpectedMessage '*Expected the actual value to be greater than 1, but got $null.*'
            { Should @(1) -BeGreaterThan 1 } | Should -Throw -ExpectedMessage '*Expected the actual value to be greater than 1, because 1, but got $null.*'

            { Should 1 -BeLessThan $null } | Should -Throw -ExpectedMessage '*Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5.*'
            Should @(1) -BeLessThan $null
            Should @(1) -BeLessThan 1
        }
    }
    Describe 'BeLike, BeLikeExactly and Match, MatchExactly' {
        #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-BeLike] [<CommonParameters>]
        # Asserts that the actual value matches a wildcard pattern using PowerShell"s -like operator. This comparison is not case-sensitive.
        #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-BeLikeExactly] [<CommonParameters>]
        # Asserts that the actual value matches a wildcard pattern using PowerShell"s -like operator. This comparison is case-sensitive.
        #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-Match] [-RegularExpression <Object>] [<CommonParameters>]
        # Uses a regular expression to compare two objects. This comparison is not case sensitive.
        #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-RegularExpression <Object>] [-MatchExactly] [<CommonParameters>]
        # Uses a regular expression to compare two objects. This comparison is case sensitive.
    }
    Describe 'BeIn' {
        #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-BeIn] [<CommonParameters>]
        # Asserts that a collection of values contain a specific value. Uses PowerShell's -contains operator to confirm.
        It 'Piped syntax' {
            1 | Should -BeIn @(1, 2, 3)
            '1' | Should -BeIn @(1, 2, 3)
            'hello' | Should -BeIn @('hello', 'world')
            'Hello' | Should -BeIn @('hello', 'world')

            { $null | Should -BeIn @() } | Should -Throw -ExpectedMessage '*Expected collection @() to contain $null, but it was not found.*'
        }
        It 'Direct syntax' {
            Should -ActualValue 1 -BeIn @(1, 2, 3)
            Should -ActualValue '1' -BeIn @(1, 2, 3)
            Should -ActualValue 'hello' -BeIn @('hello', 'world')
            Should -ActualValue 'Hello' -BeIn @('hello', 'world')

            { Should -ActualValue $null -BeIn @() } | Should -Throw -ExpectedMessage '*Expected collection @() to contain $null, but it was not found.*'
        }
        It 'Single element arrays are evaluated as the single element' {
            @(1) | Should -BeIn @(1, 2, 3)
            { Should -ActualValue @(1) -BeIn @(1, 2, 3) } | Should -Throw -ExpectedMessage '*Expected collection @(1, 2, 3) to contain 1, but it was not found.*'
        }
        It 'Arrays are evaluated element by element when piped to BeIn' {
            @(1, 2, 3) | Should -BeIn @(1, 2, 3)
            { @(1, 2, 3) | Should -BeIn @(@(1, 2, 3), @(4, 5, 6)) } | Should -Throw -ExpectedMessage '*Expected collection @(@(1, 2, 3), @(4, 5, 6)) to contain 1, but it was not found.*'
            { @(@(1, 2, 3), @(1, 2, 3)) | Should -BeIn @(@(1, 2, 3), @(4, 5, 6)) } | Should -Throw -ExpectedMessage '*Expected collection @(@(1, 2, 3), @(4, 5, 6)) to contain @(1, 2, 3), but it was not found.*'
            $obj = @(1, 2, 3)
            @($obj, $obj) | Should -BeIn @($obj, @(4, 5, 6))
        }
        It 'Arrays are evaluated as a whole when not piped' {
            { Should -ActualValue @(1, 2, 3) -BeIn @(1, 2, 3) } | Should -Throw -ExpectedMessage '*Expected collection @(1, 2, 3) to contain @(1, 2, 3), but it was not found.*'
            { Should -ActualValue @(1, 2, 3) -BeIn @(@(1, 2, 3), @(4, 5, 6)) } | Should -Throw -ExpectedMessage '*Expected collection @(@(1, 2, 3), @(4, 5, 6)) to contain @(1, 2, 3), but it was not found.*'
            $obj = @(1, 2, 3)
            Should -ActualValue $obj -BeIn @($obj, @(4, 5, 6))
        }
        It "Omitting '-ActualValue' inputs `$null to the Should command and defaults to '-ExpectedValue'" {
            { Should 1 -BeIn @(1, 2, 3) } | Should -Throw -ExpectedMessage '*Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5.*'
            { Should @(1) -BeIn @(1, 2, 3) } | Should -Throw -ExpectedMessage '*Expected collection 1 to contain $null, because 1 2 3, but it was not found.*'
        }
    }
    Describe 'Contain' {
        #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-Contain] [<CommonParameters>]
        # Asserts that collection contains a specific value. Uses PowerShell's -contains operator to confirm.
        It 'Piped syntax' {
            1 | Should -Contain 1
            @(1, 2, 3) | Should -Contain 1
            @(1, 2, 3) | Should -Contain '1'
            'hello', 'world' | Should -Contain 'hello'
            'hello', 'world' | Should -Contain 'Hello'
            
            @() | Should -Not -Contain 1
            @() | Should -Contain $null
        }
        It 'Direct syntax' {
            Should -ActualValue 1 -Contain 1
            { Should -ActualValue @(1, 2, 3) -Contain 1 } | Should -Throw -ExpectedMessage '*Expected 1 to be found in collection @(@(1, 2, 3)), but it was not found.*'
            { Should -ActualValue @(1, 2, 3) -Contain '1' } | Should -Throw -ExpectedMessage "*Expected '1' to be found in collection @(@(1, 2, 3)), but it was not found.*"
            { Should -ActualValue @('hello', 'world') -Contain 'hello' } | Should -Throw -ExpectedMessage "*Expected 'hello' to be found in collection @(@('hello', 'world')), but it was not found.*"
            { Should -ActualValue @('hello', 'world') -Contain 'Hello' } | Should -Throw -ExpectedMessage "*Expected 'Hello' to be found in collection @(@('hello', 'world')), but it was not found.*"

            Should -ActualValue @() -Not -Contain 1
            { Should -ActualValue @() -Contain $null } | Should -Throw -ExpectedMessage '*Expected $null to be found in collection @(@()), but it was not found.*'
        }
        It 'Single element arrays are evaluated as the single element' {
            @(1) | Should -Contain 1
            { Should -ActualValue @(1) -Contain 1 } | Should -Throw -ExpectedMessage '*Expected 1 to be found in collection @(1), but it was not found.*'
        }
        It 'Arrays are evaluated as a whole when piped to Contain' {
            { @(@(1, 2, 3), @(1, 2, 3)) | Should -Contain 1 } | Should -Throw -ExpectedMessage '*Expected 1 to be found in collection @(@(1, 2, 3), @(1, 2, 3)), but it was not found.*'
            { @(@(1, 2, 3), @(1, 2, 3)) | Should -Contain @(1, 2, 3) } | Should -Throw -ExpectedMessage '*Expected @(1, 2, 3) to be found in collection @(@(1, 2, 3), @(1, 2, 3)), but it was not found.*'
            $obj = @(1, 2, 3)
            @($obj, @(4, 5, 6)) | Should -Contain $obj
        }
        It 'Arrays are wrapped with another array when not piped' {
            { Should -ActualValue @(@(1, 2, 3), @(1, 2, 3)) -Contain 1 } | Should -Throw -ExpectedMessage '*Expected 1 to be found in collection @(@(@(1, 2, 3), @(1, 2, 3))), but it was not found.*'
            { Should -ActualValue @(@(1, 2, 3), @(1, 2, 3)) -Contain @(1, 2, 3) } | Should -Throw -ExpectedMessage '*Expected @(1, 2, 3) to be found in collection @(@(@(1, 2, 3), @(1, 2, 3))), but it was not found.*'
            $obj = @(1, 2, 3)
            { Should -ActualValue @($obj, @(4, 5, 6)) -Contain $obj } | Should -Throw -ExpectedMessage '*Expected @(1, 2, 3) to be found in collection @(@(@(1, 2, 3), @(4, 5, 6))), but it was not found.*'
            Should -ActualValue $obj -Contain $obj
        }
        It "Omitting '-ActualValue' inputs `$null to the Should command and defaults to '-ExpectedValue'" {
            { Should 1 -Contain 1 } | Should -Throw -ExpectedMessage '*Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5.*'
            { Should @(1) -Contain 1 } | Should -Throw -ExpectedMessage '*Expected 1 to be found in collection @($null), because 1, but it was not found.*'   
        }
    }
    Describe 'HaveCount' {
        #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-HaveCount] [<CommonParameters>]
        # Asserts that a collection has the expected amount of items.
        It 'Piped syntax' {
            @() | Should -HaveCount 0
            1 | Should -HaveCount 1
            @(1, 2, 3) | Should -HaveCount 3
            'hello', 'world' | Should -HaveCount 2
        }
        It 'Direct syntax' {
            { Should -ActualValue @() -HaveCount 0 } | Should -Throw -ExpectedMessage '*Expected an empty collection, but got collection with size 1 @(@()).*'
            Should -ActualValue 1 -HaveCount 1
            { Should -ActualValue @(1, 2, 3) -HaveCount 3 } | Should -Throw -ExpectedMessage '*Expected a collection with size 3, but got collection with size 1 @(@(1, 2, 3)).*'
            { Should -ActualValue @('hello', 'world') -HaveCount 2 } | Should -Throw -ExpectedMessage "*Expected a collection with size 2, but got collection with size 1 @(@('hello', 'world')).*"
        }
        It 'Single element arrays are evaluated as the single element' {
            @(1) | Should -HaveCount 1
            Should -ActualValue @(1) -HaveCount 1
        }
        It 'Single element arrays are unwrapped as much as possible' {
            @(@(@(1, 2))) | Should -HaveCount 2
            { Should -ActualValue @(@(1, 2)) -HaveCount 2 } | Should -Throw -ExpectedMessage '*Expected a collection with size 2, but got collection with size 1 @(@(1, 2)).*'
            { Should -ActualValue @(@(@(1, 2))) -HaveCount 2 } | Should -Throw -ExpectedMessage '*Expected a collection with size 2, but got collection with size 1 @(@(1, 2)).*'
            { Should -ActualValue @(@(@(@(1, 2)))) -HaveCount 2 } | Should -Throw -ExpectedMessage '*Expected a collection with size 2, but got collection with size 1 @(@(1, 2)).*'
            { Should -ActualValue @(@(@(@(@(1, 2))))) -HaveCount 2 } | Should -Throw -ExpectedMessage '*Expected a collection with size 2, but got collection with size 1 @(@(1, 2)).*'
        }
        It "Omitting '-ActualValue' inputs `$null to the Should command and defaults to '-ExpectedValue'" {
            { Should 1 -HaveCount 1 } | Should -Throw -ExpectedMessage '*Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5.*'
            { Should @(1) -HaveCount 1 } | Should -Throw -ExpectedMessage '*Cannot process argument transformation on parameter*'
        }
    }
    Describe 'Exist' {
        #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-Exist] [<CommonParameters>]
        # Does not perform any comparison, but checks if the object calling Exist is present in a PS Provider. The object must have valid path syntax. It essentially must pass a Test-Path call.
        It 'Piped syntax' {
            $temp_file1 = New-TemporaryFile
            $temp_file2 = New-TemporaryFile
            $full_path1 = $temp_file1.FullName
            $full_path2 = $temp_file2.FullName

            $full_path1 | Should -Exist
            $full_path2 | Should -Exist
            $full_path1, $full_path2 | Should -Exist

            $temp_file1 | Should -Exist
            $temp_file2 | Should -Exist
            $temp_file1, $temp_file2 | Should -Exist

            Remove-Item $temp_file1, $temp_file2

            $full_path1 | Should -Not -Exist
            $full_path2 | Should -Not -Exist
            $full_path1, $full_path2 | Should -Not -Exist
            
            $temp_file1 | Should -Not -Exist
            $temp_file2 | Should -Not -Exist
            $temp_file1, $temp_file2 | Should -Not -Exist
        }
        It 'Direct syntax' {
            $temp_file1 = New-TemporaryFile
            $temp_file2 = New-TemporaryFile
            $full_path1 = $temp_file1.FullName
            $full_path2 = $temp_file2.FullName

            Should -ActualValue $full_path1 -Exist
            Should -ActualValue $full_path2 -Exist
            Should -ActualValue $full_path1, $full_path2 -Exist

            Should -ActualValue $temp_file1 -Exist
            Should -ActualValue $temp_file2 -Exist
            Should -ActualValue $temp_file1, $temp_file2 -Exist

            Remove-Item $temp_file1, $temp_file2

            Should -ActualValue $full_path1 -Not -Exist
            Should -ActualValue $full_path2 -Not -Exist
            { Should -ActualValue $full_path1, $full_path2 -Not -Exist } | Should -Throw -ExpectedMessage '*Expected path @(*) to not exist, but it did exist.*'

            Should -ActualValue $temp_file1 -Not -Exist
            Should -ActualValue $temp_file2 -Not -Exist
            { Should -ActualValue $temp_file1, $temp_file2 -Not -Exist } | Should -Throw -ExpectedMessage '*Expected path @(*) to not exist, but it did exist.*'
        }
        It "'-ActualValue' array input always exists" {
            $temp_file1 = 'InvalidePath!(1)'
            $temp_file2 = 'InvalidePath!(2)'
            Should -ActualValue @($temp_file1, $temp_file2) -Exist
        }
        It "Omitting '-ActualValue' inputs `$null to the Should command and defaults to '-ExpectedValue'" {
            { Should '.' -Exist } | Should -Throw -ExpectedMessage '*Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5.*'
            { Should @('.') -Exist } | Should -Throw -ExpectedMessage '*Expected path $null to exist, because ., but it did not exist.*'
        }
    }
    # $succeeded = (@(& $SafeCommands['Get-Content'] -Encoding UTF8 $ActualValue) -match $ExpectedContent).Count -gt 0
    # $succeeded = [bool] ((& $SafeCommands['Get-Content'] $ActualValue -Delimiter ([char]0)) -match $ExpectedContent)
    Describe 'FileContentMatch and FileContentMatchExactly, FileContentMatchMultiline and FileContentMatchMultilineExactly' {
        #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-FileContentMatch] [-ExpectedContent <Object>] [<CommonParameters>]
        # Checks to see if a file contains the specified text. This search is not case sensitive and uses regular expressions.
        #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-ExpectedContent <Object>] [-FileContentMatchExactly] [<CommonParameters>]
        # Checks to see if a file contains the specified text. This search is case sensitive and uses regular expressions to match the text.

        #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-ExpectedContent <Object>] [-FileContentMatchMultiline] [<CommonParameters>]
        #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-ExpectedContent <Object>] [-FileContentMatchMultilineExactly] [<CommonParameters>]

        It 'Piped syntax' {
            $temp_file1 = New-TemporaryFile
            $temp_file2 = New-TemporaryFile
            $full_path1 = $temp_file1.FullName
            $full_path2 = $temp_file2.FullName

            'hello world' | Out-File $temp_file1 -Append
            'hello world' | Out-File $temp_file2 -Append
            'Hello world' | Out-File $temp_file2 -Append

            $temp_file1 | Should -FileContentMatch 'hello world$'
            $temp_file1 | Should -FileContentMatch 'Hello world$'
            $temp_file1 | Should -FileContentMatchExactly 'hello world$'
            { $temp_file1 | Should -FileContentMatchExactly 'Hello world$' } | Should -Throw -ExpectedMessage "*Expected 'Hello world$' to be case sensitively found in file *, but it was not found.*"
            { $temp_file1 | Should -FileContentMatchMultiline 'hello world$' } | Should -Throw -ExpectedMessage "*Expected 'hello world$' to be found in file *, but it was not found.*"
            $temp_file1 | Should -FileContentMatchMultiline 'hello world\r\n$'
            $temp_file1 | Should -FileContentMatchMultiline 'Hello world\r\n$'
            $temp_file1 | Should -FileContentMatchMultilineExactly 'hello world\r\n$'
            { $temp_file1 | Should -FileContentMatchMultilineExactly 'Hello world\r\n$' } | Should -Throw -ExpectedMessage "*Expected 'Hello world\r\n$' to be case sensitively found in file *, but it was not found.*"

            $temp_file2 | Should -FileContentMatch 'hello world$'
            $temp_file2 | Should -FileContentMatch 'Hello world$'
            $temp_file2 | Should -FileContentMatchExactly 'hello world$'
            $temp_file2 | Should -FileContentMatchExactly 'Hello world$'
            { $temp_file2 | Should -FileContentMatchMultiline 'hello world$' } | Should -Throw -ExpectedMessage "*Expected 'hello world$' to be found in file *, but it was not found.*"
            $temp_file2 | Should -FileContentMatchMultiline 'hello world\r\n$'
            $temp_file2 | Should -FileContentMatchMultiline 'Hello world\r\n$'
            { $temp_file2 | Should -FileContentMatchMultilineExactly 'hello world\r\n$' } | Should -Throw -ExpectedMessage "*Expected 'hello world\r\n$' to be case sensitively found in file *, but it was not found.*"
            $temp_file2 | Should -FileContentMatchMultilineExactly 'Hello world\r\n$'

            $temp_file1, $temp_file2 | Should -FileContentMatch 'hello world$'
            $temp_file1, $temp_file2 | Should -FileContentMatch 'Hello world$'
            $temp_file1, $temp_file2 | Should -FileContentMatchExactly 'hello world$'
            { $temp_file1, $temp_file2 | Should -FileContentMatchExactly 'Hello world$' } | Should -Throw -ExpectedMessage "*Expected 'Hello world$' to be case sensitively found in file *, but it was not found.*"
            { $temp_file1, $temp_file2 | Should -FileContentMatchMultiline 'hello world$' } | Should -Throw -ExpectedMessage "*Expected 'hello world$' to be found in file *, but it was not found.*"
            $temp_file1, $temp_file2 | Should -FileContentMatchMultiline 'hello world\r\n$'
            $temp_file1, $temp_file2 | Should -FileContentMatchMultiline 'Hello world\r\n$'
            { $temp_file1, $temp_file2 | Should -FileContentMatchMultilineExactly 'hello world\r\n$' } | Should -Throw -ExpectedMessage "*Expected 'hello world\r\n$' to be case sensitively found in file *, but it was not found.*"
            { $temp_file1, $temp_file2 | Should -FileContentMatchMultilineExactly 'Hello world\r\n$' } | Should -Throw -ExpectedMessage "*Expected 'Hello world\r\n$' to be case sensitively found in file *, but it was not found.*"
            
            { $temp_file1 | Should -FileContentMatchMultilineExactly '^hello world\r\nHello world\r\n$' } | Should -Throw -ExpectedMessage "*Expected '^hello world\r\nHello world\r\n$' to be case sensitively found in file *, but it was not found.*"
            $temp_file2 | Should -FileContentMatchMultilineExactly '^hello world\r\nHello world\r\n$'
            #

            $full_path1 | Should -FileContentMatch 'hello world$'
            $full_path1 | Should -FileContentMatch 'Hello world$'
            $full_path1 | Should -FileContentMatchExactly 'hello world$'
            { $full_path1 | Should -FileContentMatchExactly 'Hello world$' } | Should -Throw -ExpectedMessage "*Expected 'Hello world$' to be case sensitively found in file *, but it was not found.*"
            { $full_path1 | Should -FileContentMatchMultiline 'hello world$' } | Should -Throw -ExpectedMessage "*Expected 'hello world$' to be found in file *, but it was not found.*"
            $full_path1 | Should -FileContentMatchMultiline 'hello world\r\n$'
            $full_path1 | Should -FileContentMatchMultiline 'Hello world\r\n$'
            $full_path1 | Should -FileContentMatchMultilineExactly 'hello world\r\n$'
            { $full_path1 | Should -FileContentMatchMultilineExactly 'Hello world\r\n$' } | Should -Throw -ExpectedMessage "*Expected 'Hello world\r\n$' to be case sensitively found in file *, but it was not found.*"

            $full_path2 | Should -FileContentMatch 'hello world$'
            $full_path2 | Should -FileContentMatch 'Hello world$'
            $full_path2 | Should -FileContentMatchExactly 'hello world$'
            $full_path2 | Should -FileContentMatchExactly 'Hello world$'
            { $full_path2 | Should -FileContentMatchMultiline 'hello world$' } | Should -Throw -ExpectedMessage "*Expected 'hello world$' to be found in file *, but it was not found.*"
            $full_path2 | Should -FileContentMatchMultiline 'hello world\r\n$'
            $full_path2 | Should -FileContentMatchMultiline 'Hello world\r\n$'
            { $full_path2 | Should -FileContentMatchMultilineExactly 'hello world\r\n$' } | Should -Throw -ExpectedMessage "*Expected 'hello world\r\n$' to be case sensitively found in file *, but it was not found.*"
            $full_path2 | Should -FileContentMatchMultilineExactly 'Hello world\r\n$'

            $full_path1, $full_path2 | Should -FileContentMatch 'hello world$'
            $full_path1, $full_path2 | Should -FileContentMatch 'Hello world$'
            $full_path1, $full_path2 | Should -FileContentMatchExactly 'hello world$'
            { $full_path1, $full_path2 | Should -FileContentMatchExactly 'Hello world$' } | Should -Throw -ExpectedMessage "*Expected 'Hello world$' to be case sensitively found in file *, but it was not found.*"
            { $full_path1, $full_path2 | Should -FileContentMatchMultiline 'hello world$' } | Should -Throw -ExpectedMessage "*Expected 'hello world$' to be found in file *, but it was not found.*"
            $full_path1, $full_path2 | Should -FileContentMatchMultiline 'hello world\r\n$'
            $full_path1, $full_path2 | Should -FileContentMatchMultiline 'Hello world\r\n$'
            { $full_path1, $full_path2 | Should -FileContentMatchMultilineExactly 'hello world\r\n$' } | Should -Throw -ExpectedMessage "*Expected 'hello world\r\n$' to be case sensitively found in file *, but it was not found.*"
            { $full_path1, $full_path2 | Should -FileContentMatchMultilineExactly 'Hello world\r\n$' } | Should -Throw -ExpectedMessage "*Expected 'Hello world\r\n$' to be case sensitively found in file *, but it was not found.*"
            
            { $full_path1 | Should -FileContentMatchMultilineExactly '^hello world\r\nHello world\r\n$' } | Should -Throw -ExpectedMessage "*Expected '^hello world\r\nHello world\r\n$' to be case sensitively found in file *, but it was not found.*"
            $full_path2 | Should -FileContentMatchMultilineExactly '^hello world\r\nHello world\r\n$'
        }
        It 'Direct syntax' {
            $temp_file1 = New-TemporaryFile
            $temp_file2 = New-TemporaryFile
            $full_path1 = $temp_file1.FullName
            $full_path2 = $temp_file2.FullName

            'hello world' | Out-File $temp_file1 -Append
            'hello world' | Out-File $temp_file2 -Append
            'Hello world' | Out-File $temp_file2 -Append

            Should -ActualValue $temp_file1 -FileContentMatch 'hello world$'
            Should -ActualValue $temp_file1 -FileContentMatch 'Hello world$'
            Should -ActualValue $temp_file1 -FileContentMatchExactly 'hello world$'
            { Should -ActualValue $temp_file1 -FileContentMatchExactly 'Hello world$' } | Should -Throw -ExpectedMessage "*Expected 'Hello world$' to be case sensitively found in file *, but it was not found.*"
            { Should -ActualValue $temp_file1 -FileContentMatchMultiline 'hello world$' } | Should -Throw -ExpectedMessage "*Expected 'hello world$' to be found in file *, but it was not found.*"
            Should -ActualValue $temp_file1 -FileContentMatchMultiline 'hello world\r\n$'
            Should -ActualValue $temp_file1 -FileContentMatchMultiline 'Hello world\r\n$'
            Should -ActualValue $temp_file1 -FileContentMatchMultilineExactly 'hello world\r\n$'
            { Should -ActualValue $temp_file1 -FileContentMatchMultilineExactly 'Hello world\r\n$' } | Should -Throw -ExpectedMessage "*Expected 'Hello world\r\n$' to be case sensitively found in file *, but it was not found.*"

            Should -ActualValue $temp_file2 -FileContentMatch 'hello world$'
            Should -ActualValue $temp_file2 -FileContentMatch 'Hello world$'
            Should -ActualValue $temp_file2 -FileContentMatchExactly 'hello world$'
            Should -ActualValue $temp_file2 -FileContentMatchExactly 'Hello world$'
            { Should -ActualValue $temp_file2 -FileContentMatchMultiline 'hello world$' } | Should -Throw -ExpectedMessage "*Expected 'hello world$' to be found in file *, but it was not found.*"
            Should -ActualValue $temp_file2 -FileContentMatchMultiline 'hello world\r\n$'
            Should -ActualValue $temp_file2 -FileContentMatchMultiline 'Hello world\r\n$'
            { Should -ActualValue $temp_file2 -FileContentMatchMultilineExactly 'hello world\r\n$' } | Should -Throw -ExpectedMessage "*Expected 'hello world\r\n$' to be case sensitively found in file *, but it was not found.*"
            Should -ActualValue $temp_file2 -FileContentMatchMultilineExactly 'Hello world\r\n$'

            Should -ActualValue $temp_file1, $temp_file2 -FileContentMatch 'hello world$'
            Should -ActualValue $temp_file1, $temp_file2 -FileContentMatch 'Hello world$'
            Should -ActualValue $temp_file1, $temp_file2 -FileContentMatchExactly 'hello world$'
            { { Should -ActualValue $temp_file1, $temp_file2 -FileContentMatchExactly 'Hello world$' } | Should -Throw } | Should -Throw -ExpectedMessage '*Expected an exception to be thrown, but no exception was thrown.*'
            { Should -ActualValue $temp_file1, $temp_file2 -FileContentMatchMultiline 'hello world$' } | Should -Throw -ExpectedMessage "*Expected 'hello world$' to be found in file *, but it was not found.*"
            Should -ActualValue $temp_file1, $temp_file2 -FileContentMatchMultiline 'hello world\r\n$'
            Should -ActualValue $temp_file1, $temp_file2 -FileContentMatchMultiline 'Hello world\r\n$'
            { { Should -ActualValue $temp_file1, $temp_file2 -FileContentMatchMultilineExactly 'hello world\r\n$' } | Should -Throw } | Should -Throw -ExpectedMessage '*Expected an exception to be thrown, but no exception was thrown.*'
            { { Should -ActualValue $temp_file1, $temp_file2 -FileContentMatchMultilineExactly 'Hello world\r\n$' } | Should -Throw } | Should -Throw -ExpectedMessage '*Expected an exception to be thrown, but no exception was thrown.*'
            
            { Should -ActualValue $temp_file1 -FileContentMatchMultilineExactly '^hello world\r\nHello world\r\n$' } | Should -Throw -ExpectedMessage "*Expected '^hello world\r\nHello world\r\n$' to be case sensitively found in file *, but it was not found.*"
            Should -ActualValue $temp_file2 -FileContentMatchMultilineExactly '^hello world\r\nHello world\r\n$'

            #
            Should -ActualValue $full_path1 -FileContentMatch 'hello world$'
            Should -ActualValue $full_path1 -FileContentMatch 'Hello world$'
            Should -ActualValue $full_path1 -FileContentMatchExactly 'hello world$'
            { Should -ActualValue $full_path1 -FileContentMatchExactly 'Hello world$' } | Should -Throw -ExpectedMessage "*Expected 'Hello world$' to be case sensitively found in file *, but it was not found.*"
            { Should -ActualValue $full_path1 -FileContentMatchMultiline 'hello world$' } | Should -Throw -ExpectedMessage "*Expected 'hello world$' to be found in file *, but it was not found.*"
            Should -ActualValue $full_path1 -FileContentMatchMultiline 'hello world\r\n$'
            Should -ActualValue $full_path1 -FileContentMatchMultiline 'Hello world\r\n$'
            Should -ActualValue $full_path1 -FileContentMatchMultilineExactly 'hello world\r\n$'
            { Should -ActualValue $full_path1 -FileContentMatchMultilineExactly 'Hello world\r\n$' } | Should -Throw -ExpectedMessage "*Expected 'Hello world\r\n$' to be case sensitively found in file *, but it was not found.*"

            Should -ActualValue $full_path2 -FileContentMatch 'hello world$'
            Should -ActualValue $full_path2 -FileContentMatch 'Hello world$'
            Should -ActualValue $full_path2 -FileContentMatchExactly 'hello world$'
            Should -ActualValue $full_path2 -FileContentMatchExactly 'Hello world$'
            { Should -ActualValue $full_path2 -FileContentMatchMultiline 'hello world$' } | Should -Throw -ExpectedMessage "*Expected 'hello world$' to be found in file *, but it was not found.*"
            Should -ActualValue $full_path2 -FileContentMatchMultiline 'hello world\r\n$'
            Should -ActualValue $full_path2 -FileContentMatchMultiline 'Hello world\r\n$'
            { Should -ActualValue $full_path2 -FileContentMatchMultilineExactly 'hello world\r\n$' } | Should -Throw -ExpectedMessage "*Expected 'hello world\r\n$' to be case sensitively found in file *, but it was not found.*"
            Should -ActualValue $full_path2 -FileContentMatchMultilineExactly 'Hello world\r\n$'

            Should -ActualValue $full_path1, $full_path2 -FileContentMatch 'hello world$'
            Should -ActualValue $full_path1, $full_path2 -FileContentMatch 'Hello world$'
            Should -ActualValue $full_path1, $full_path2 -FileContentMatchExactly 'hello world$'
            { { Should -ActualValue $full_path1, $full_path2 -FileContentMatchExactly 'Hello world$' } | Should -Throw } | Should -Throw -ExpectedMessage '*Expected an exception to be thrown, but no exception was thrown.*'
            { Should -ActualValue $full_path1, $full_path2 -FileContentMatchMultiline 'hello world$' } | Should -Throw -ExpectedMessage "*Expected 'hello world$' to be found in file *, but it was not found.*"
            Should -ActualValue $full_path1, $full_path2 -FileContentMatchMultiline 'hello world\r\n$'
            Should -ActualValue $full_path1, $full_path2 -FileContentMatchMultiline 'Hello world\r\n$'
            { { Should -ActualValue $full_path1, $full_path2 -FileContentMatchMultilineExactly 'hello world\r\n$' } | Should -Throw } | Should -Throw -ExpectedMessage '*Expected an exception to be thrown, but no exception was thrown.*'
            { { Should -ActualValue $full_path1, $full_path2 -FileContentMatchMultilineExactly 'Hello world\r\n$' } | Should -Throw } | Should -Throw -ExpectedMessage '*Expected an exception to be thrown, but no exception was thrown.*'
            
            { Should -ActualValue $full_path1 -FileContentMatchMultilineExactly '^hello world\r\nHello world\r\n$' } | Should -Throw -ExpectedMessage "*Expected '^hello world\r\nHello world\r\n$' to be case sensitively found in file *, but it was not found.*"
            Should -ActualValue $full_path2 -FileContentMatchMultilineExactly '^hello world\r\nHello world\r\n$'
        }
        It "Omitting '-ActualValue' inputs `$null to the Should command and defaults to '-ExpectedValue'" {
            $temp_file1 = New-TemporaryFile
            $full_path1 = $temp_file1.FullName

            'hello world' | Out-File $temp_file1 -Append
            
            { Should $temp_file1 -FileContentMatch 'hello world$' } | Should -Throw -ExpectedMessage '*Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5.*'
            { Should @($temp_file1) -FileContentMatch 'hello world$' } | Should -Throw -ExpectedMessage "*Cannot bind argument to parameter 'Path' because it is null.*"

            { Should $temp_file1 -FileContentMatchExactly 'hello world$' } | Should -Throw -ExpectedMessage '*Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5.*'
            { Should @($temp_file1) -FileContentMatchExactly 'hello world$' } | Should -Throw -ExpectedMessage "*Cannot bind argument to parameter 'Path' because it is null.*"

            { Should $temp_file1 -FileContentMatchMultiline 'hello world$' } | Should -Throw -ExpectedMessage '*Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5.*'
            { Should @($temp_file1) -FileContentMatchMultiline 'hello world$' } | Should -Throw -ExpectedMessage "*Cannot bind argument to parameter 'Path' because it is null.*"

            { Should $temp_file1 -FileContentMatchMultilineExactly 'hello world$' } | Should -Throw -ExpectedMessage '*Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5.*'
            { Should @($temp_file1) -FileContentMatchMultilineExactly 'hello world$' } | Should -Throw -ExpectedMessage "*Cannot bind argument to parameter 'Path' because it is null.*"

            { Should $full_path1 -FileContentMatch 'hello world$' } | Should -Throw -ExpectedMessage '*Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5.*'
            { Should @($full_path1) -FileContentMatch 'hello world$' } | Should -Throw -ExpectedMessage "*Cannot bind argument to parameter 'Path' because it is null.*"

            { Should $full_path1 -FileContentMatchExactly 'hello world$' } | Should -Throw -ExpectedMessage '*Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5.*'
            { Should @($full_path1) -FileContentMatchExactly 'hello world$' } | Should -Throw -ExpectedMessage "*Cannot bind argument to parameter 'Path' because it is null.*"

            { Should $full_path1 -FileContentMatchMultiline 'hello world$' } | Should -Throw -ExpectedMessage '*Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5.*'
            { Should @($full_path1) -FileContentMatchMultiline 'hello world$' } | Should -Throw -ExpectedMessage "*Cannot bind argument to parameter 'Path' because it is null.*"

            { Should $full_path1 -FileContentMatchMultilineExactly 'hello world$' } | Should -Throw -ExpectedMessage '*Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5.*'
            { Should @($full_path1) -FileContentMatchMultilineExactly 'hello world$' } | Should -Throw -ExpectedMessage "*Cannot bind argument to parameter 'Path' because it is null.*"
        }

    }
    Describe 'HaveParameter' {
        #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-HaveParameter] [-ParameterName <Object>] [-Type <Object>] [-DefaultValue <Object>] [-Mandatory] [-InParameterSet <Object>] [-HasArgumentCompleter] [-Alias <Object>] [<CommonParameters>]
        #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-Throw] [-ExpectedMessage <Object>] [-ErrorId <Object>] [-ExceptionType <Object>] [-PassThru] [<CommonParameters>]
        #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-InvokeVerifiable] [<CommonParameters>]
        #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-Invoke] [-CommandName <Object>] [-Times <Object>] [-ParameterFilter <Object>] [-ExclusiveFilter <Object>] [-ModuleName <Object>] [-Scope <Object>] [-Exactly] [-CallerSessionState <Object>] [<CommonParameters>] [<CommonParameters>]
        It 'Piped syntax' {
        }
        It 'Direct syntax' {
        }
        It "Omitting '-ActualValue' inputs `$null to the Should command and defaults to '-ExpectedValue'" {
        }

    }
    Describe 'BeOfType' {
        #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-BeOfType] [-ExpectedType <Object>] [<CommonParameters>]
        It 'Piped syntax' {
        }
        It 'Direct syntax' {
        }
        It "Omitting '-ActualValue' inputs `$null to the Should command and defaults to '-ExpectedValue'" {
        }

        # ps classes
        # c# classes
        # inheritance?
        # interfaces?
    }
}








# BeforeDiscovery {
#     $array_types = @( { [System.Object[]] }, { [System.Array] }, { [System.Collections.ICollection] }, { [System.ICloneable] }, { [System.Collections.IList] }, { [System.Collections.ICollection] }, { [System.Collections.IEnumerable] }, { [System.Collections.IStructuralComparable] }, { [System.Collections.IStructuralEquatable] })
#     $hashtable_types = @( { [System.Collections.Hashtable] }, { [System.Collections.IDictionary] }, { [System.Collections.ICollection] }, { [System.Collections.IEnumerable] }, { [System.Runtime.Serialization.ISerializable] }, { [System.Runtime.Serialization.IDeserializationCallback] }, { [System.ICloneable] } ) 
#     $pscustomobject_types = @( { [System.Management.Automation.PSObject], { [System.IFormattable] }, { [System.IComparable] }, { [System.Runtime.Serialization.ISerializable] }, { [System.Dynamic.IDynamicMetaObjectProvider] } })

#     $pscustomobject_not_types = @( { [System.Collections.IDictionary] }, { [System.Collections.ICollection] })

#     @{
    
#         Title            = 'Title'
    
#         PipeSyntax       = $true
    
#         DirectSyntax     = $true
#         # Equivilence
#         obj              = @( {}, {} , {} ) # beexactly, be
#         be               = @( {}, {} , {} ) # be - extra be without exactly checks
#         not_be_exactly   = @( {}, {} , {} ) # not beexactly, be
#         not_be           = @( {}, {} , {} ) # not be, not exactly
#         truthy           = $true; # betrue, befalse
#         nullempty        = $true; #BeNullOrEmpty
#         # Order
#         lessthan         = @( {}, {} , {} ) # belessthan
#         greaterthan      = @( {}, {} , {} ) # begreaterthan
#         lessthanequal    = @( {}, {} , {} ) # belessthanorequal
#         greaterthanequal = @( {}, {} , {} ) # begreaterthanorequal
#         # Collection
#         contain          = @( {}, {}, {}) #contain
#         not_contain      = @( {}, {}, {}) #not contain
#         types            = @( {}, {}, {}) #beoftype
#         not_types        = @( {}, {}, {}) #not beoftype
#         havecount        = @( {}, {}, {}) #havecount
#         not_havecount    = @( {}, {}, {}) #nothavecount
#         #files
#         #functions
#     }

#     $unintuitive = @(
#         @{pipe_syntax = $true; Title = 'Piped syntax equivilence $null'; obj_exactly = @( { $null }, { @($null) }, { @() }); _truthy = $false; _nullempty = $true; _contain = @( { $null }) ; _type = $array_types; _not_type = @( {} ) },
#     )
#     $collections = @(
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Array - ($null)'; obj = { @($null) }; _truthy = $false; _nullempty = $true; _contain = @( { $null }) ; _type = $array_types },
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Array - ($true)'; obj = { @($true) }; _truthy = $true; _nullempty = $false; _contain = @( { $true }), { 1 } , { 2 }, { 'non empty string' }; _not_contain = @() ; _type = $array_types; _not_type = @( {} ) },
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Array - ($false)'; obj = { @($false) }; _truthy = $false; _nullempty = $false; _contain = @( { $false }, { 0 }, { '' }) ; _not_contain = @( ) ; _type = $array_types; _not_type = @( {} ) },
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Array - (1)'; obj = { @(1) }; _truthy = $true; _nullempty = $false; _not_contain = @( { 2 } ) ; _contain = @( { 1 }, { '1' }) ; _type = $array_types; _not_type = @( {} ) },
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Array - Array - Empty'; obj = { @(@()) }; _isReference = $true; _truthy = $false; _nullempty = $true; _not_contain = @( { @() }) ; _type = $array_types; _not_type = @( {} ) },
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Array - Element order'; obj = { @('one', 'two', 'three') }; obj_not_exactly = { @('One', 'Two', 'Three') }; _truthy = $true; _nullempty = $false; ; _contain = @( { 'one' }, { 'two' }, { 'three' }, { 'One' }, { 'Two' }, { 'Three' }) ; _type = $array_types; _not_type = @( {} ) },
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Array - Element order'; obj = { @(1, 2, 3) }; not_equal = { @(2, 1, 3) }; _truthy = $true; _nullempty = $false; _not_contain = @( { 4 }); _contain = @( { 1 }, { 2 }, { 3 }, { '1' }, { '2' }, { '3' }) ; _type = $array_types; _not_type = @( {} ) },
#         @{direct_syntax = $true ; Title = 'Array - Empty'; obj = { @() }; _truthy = $false; _nullempty = $false; _not_contain = @( { $null }) ; _type = $array_types; _not_type = @( {} ) },
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Array - Hashtable - Empty'; obj = { @(@{}) }; _isReference = $true; _truthy = $true; _nullempty = $true; _not_contain = @( { @{} }) ; _type = $array_types; _not_type = @( {} ) },
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Array - PSObject - Empty'; obj = { @([PSCustomObject]@{}) }; _isReference = $true; _truthy = $true; _nullempty = $true; _not_contain = @( { [PSCustomObject]@{} }) ; _type = $array_types; _not_type = @( {} ) },
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Hashtable - Empty'; obj = { @{} }; _isReference = $true; _truthy = $true; _nullempty = $true; _not_contain = @( { $null }) ; _type = $hashtable_types },
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Hashtable'; obj = { @{ 'Name' = 'John'; 'Age' = 30 } }; _isReference = $true; ; _truthy = $true; _nullempty = $false; _not_contain = @( { 'Name' }, { 'John' }, { 'Age' }, { 30 } ) ; _type = $hashtable_types; },
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'PSCustomObject - Empty'; obj = { [PSCustomObject]@{} }; _isReference = $true; ; _truthy = $true; _nullempty = $true; _not_contain = @( { $null } ) ; _type = $pscustomobject_types ; _not_type = $pscustomobject_not_types },
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'PSCustomObject'; obj = { [PSCustomObject]@{ 'Name' = 'John'; 'Age' = 30 } }; _isReference = $true; ; _truthy = $true; _nullempty = $false; _not_contain = @( { 'Name' }, { 'John' }, { 'Age' }, { 30 } ) ; _type = $pscustomobject_types ; _not_type = $pscustomobject_not_types }
#     )
#     $primitives = @(
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Boolean'; obj = { $false }; not_equal = { $true }; _truthy = $false; _nullempty = $false; _type = @(  [System.Boolean], [System.ValueType] ); _not_type = @( {} ) },
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Boolean'; obj = { $true }; not_equal = { $false }; _truthy = $true; _nullempty = $false; _type = @( {} ); _not_type = @( {} ) },
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'null'; obj = { $null }; _ordered = $true ; _truthy = $false; _nullempty = $true; _type = @( {} ); _not_type = @( {} ) },
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Numbers - floating point'; obj = { 3.14 }; _ordered = $true ; _truthy = $true; _nullempty = $false; _type = @( {} ); _not_type = @( {} ) },
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Numbers'; obj = { 0 }; ; _ordered = $true ; _truthy = $false; _nullempty = $false; _type = @( {} ); _not_type = @( {} ) },
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Numbers'; obj = { 1 }; ; _ordered = $true ; _truthy = $true; _nullempty = $false; _type = @( {} ); _not_type = @( {} ) },
#     )
#     $strings = @(
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'String - Empty'; obj = { '' }; _ordered = $true ; _truthy = $false; _nullempty = $true; _type = @( {} ); _not_type = @( {} ) },
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'String - lexicographically'; obj = { 'abc' }; obj_not_exactly = { 'ABC' }; ; _truthy = $true; _nullempty = $false; _type = @( {} ); _not_type = @( {} ) },



#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'String'; obj = { 'Hello World' }; obj_not_exactly = { 'hello World' }; not_equal = { 'Hello World!' }; _ordered = $true ; _truthy = $true; _nullempty = $false; _type = @( {} ); _not_type = @( {} ) }
#     )
#     $csharp_objects = @(


#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'DateTime - same date'; obj = { Get-Date -Year 2022 -Month 1 -Day 1 } ; _isReference = $true; _truthy = $true; _nullempty = $false; _type = @( {} ); _not_type = @( {} ) }, # strictly less 
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'GUID'; obj = { [Guid]'00000000-0000-0000-0000-000000000000' }; _ordered = $true; _truthy = $true; _nullempty = $false; _type = @( {} ); _not_type = @( {} ) },
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'TimeSpan'; obj = { New-TimeSpan -Days 1 }; _ordered = $true ; _truthy = $true; _nullempty = $false; _type = @( {} ); _not_type = @( {} ) },

#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Version'; obj = { [Version]'1.2.3' }; _ordered = $true ; _truthy = $true; _nullempty = $false; _type = @( {} ); _not_type = @( {} ) }
#     )
#     $misc = @(
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Scriptblock - Empty'; obj = { {} }; _isReference = $true; _truthy = $true; _nullempty = $true; _type = @( {} ); _not_type = @( {} ) }
#     )
#     $files = @(
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'File - Empty'; obj = { Get-Item -Path $null }; _isReference = $true; _truthy = $true; _nullempty = $true; _type = @( {} ); _not_type = @( {} ) }
#     )
#     $classes = @(
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Class' ; _setup = {} ; obj = { $instance }; _type = @( {} ); _not_type = @( {} ) }
#     )
#     $functions = @(
#         @{pipe_syntax = $true; direct_syntax = $true ; Title = 'Function' ; _setup = { function Test-Function {} } ; obj = { Test-Function }; _type = @( {} ); _not_type = @( {} ) }
#     )
# }
# Describe 'Should examples' {
#     Describe 'Custom' {

#     }
#     Describe 'Object Operations' {
#         Describe 'BeOfType' {
#             #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-BeOfType] [-ExpectedType <Object>] [<CommonParameters>]
#             # Asserts that the actual value should be an object of a specified type (or a subclass of the specified type) using PowerShell's -is operator.
#         }
#     }
#     Describe 'Order, Equalities and Pattern Matching' -ForEach (  $collections  ) {
#         Describe '<_>' {
#             Describe 'BeTrue' {
#                 #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-BeTrue] [<CommonParameters>]
#                 # Asserts that the value is true, or truthy.
#                 try {
#                     $truthy = Get-Variable _truthy -ValueOnly -ErrorAction Stop
#                     $scriptblock = ([ScriptBlock]::Create("($obj) | Should $(if(-not $truthy){'-Not '})-BeTrue"))
#                     Write-Host $scriptblock
#                     It "$Title" $scriptblock

#                 }
#                 catch {}
#             }

#             Describe 'BeFalse' {
#                 #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-BeFalse] [<CommonParameters>]
#                 # Asserts that the value is false, or falsy.
#                 try {
#                     $truthy = Get-Variable _truthy -ValueOnly -ErrorAction Stop
#                     $scriptblock = ([ScriptBlock]::Create("($obj) | Should $(if($truthy){'-Not '})-BeFalse"))
#                     Write-Host $scriptblock
#                     It "$Title" $scriptblock
#                 }
#                 catch {}
#             }
#             Describe 'BeNullOrEmpty' {
#                 #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-BeNullOrEmpty] [<CommonParameters>]
#                 # Checks values for null or empty (strings). The static [String]::IsNullOrEmpty() method is used to do the comparison.
#                 # 
#                 try {
#                     $nullempty = Get-Variable _nullempty -ValueOnly -ErrorAction Stop
#                     $scriptblock = ([ScriptBlock]::Create("($obj) | Should $(if(-not $nullempty){'-Not '})-BeNullOrEmpty"))
#                     Write-Host $scriptblock
#                     It "$Title" $scriptblock
#                 }
#                 catch {}
#             }
#             Describe 'Be' {
#                 #? Should [[-ActualValue] <Object>] [-Be] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [<CommonParameters>]
#                 # Compares one object with another for equality and throws if the two objects are not the same. This comparison is case insensitive.
#                 # https://www.sharepointdiary.com/2021/10/powershell-compare-object.html
#                 if ($obj) {
#                     $scriptblock = ([ScriptBlock]::Create("($obj) | Should $(if($_isReference){'-Not '})-Be ($obj)"))
#                     $scriptblock_reference = ([ScriptBlock]::Create("`$obj = ($obj); `$obj | Should -Be `$obj"))
#                     Write-Host $scriptblock
#                     It "$Title - Be equality check" $scriptblock
#                     if ($_isReference) {
#                         Write-Host $scriptblock_reference
#                         It "$Title - Reference" $scriptblock_reference
#                     }
#                 }
#                 if ($obj -and $obj_not_exactly) {
#                     $scriptblock = ([ScriptBlock]::Create("($obj) | Should -Be ($obj_not_exactly)"))
#                     Write-Host $scriptblock
#                     It "$Title" $scriptblock
#                 }
#                 if ($obj -and $not_equal) {
#                     $scriptblock = ([ScriptBlock]::Create("($obj) | Should -Not -Be ($not_equal)"))
#                     Write-Host $scriptblock
#                     It "$Title" $scriptblock
#                 }
#             }

#             Describe 'BeExactly' {
#                 #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-BeExactly] [<CommonParameters>]
#                 # Compares one object with another for equality and throws if the two objects are not the same. This comparison is case sensitive.
#                 if ($obj) {
#                     $scriptblock = ([ScriptBlock]::Create("($obj) | Should $(if($_isReference){'-Not '})-BeExactly ($obj)"))
#                     $scriptblock_reference = ([ScriptBlock]::Create("`$obj = ($obj); `$obj | Should -BeExactly `$obj"))
#                     Write-Host $scriptblock
#                     It "$Title" $scriptblock
#                     Write-Host $scriptblock_reference
#                     if ($_isReference) {
#                         It "$Title - Reference" $scriptblock_reference
#                     }
#                 }
#                 if ($obj -and $obj_not_exactly) {
#                     $scriptblock = ([ScriptBlock]::Create("($obj) | Should -Be ($obj_not_exactly)"))
#                     Write-Host $scriptblock
#                     It "$Title" $scriptblock
#                     $scriptblock = ([ScriptBlock]::Create("($obj) | Should -Not -BeExactly ($obj_not_exactly)"))
#                     Write-Host $scriptblock
#                     It "$Title" $scriptblock
#                 }
#                 if ($obj -and $not_equal) {
#                     $scriptblock = ([ScriptBlock]::Create("($obj) | Should -Not -BeExactly ($not_equal)"))
#                     Write-Host $scriptblock
#                     It "$Title" $scriptblock
#                 }
#             }
#             Describe 'BeLike' {
#                 #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-BeLike] [<CommonParameters>]
#                 # Asserts that the actual value matches a wildcard pattern using PowerShell"s -like operator. This comparison is not case-sensitive.
               
#             }

#             Describe 'BeLikeExactly' {
#                 #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-BeLikeExactly] [<CommonParameters>]
#                 # Asserts that the actual value matches a wildcard pattern using PowerShell"s -like operator. This comparison is case-sensitive.
                
#             }
#             Describe 'Match' {
#                 #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-Match] [-RegularExpression <Object>] [<CommonParameters>]
#                 # Uses a regular expression to compare two objects. This comparison is not case sensitive.
                
#             }

#             Describe 'MatchExactly' {
#                 #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-RegularExpression <Object>] [-MatchExactly] [<CommonParameters>]
#                 # Uses a regular expression to compare two objects. This comparison is case sensitive.
#             }
#         }
#         Describe 'Ordered comparisons' {
#             Describe 'BeGreaterThan' {
#                 #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-BeGreaterThan] [<CommonParameters>]
#                 # Asserts that a number (or other comparable value) is greater than an expected value. Uses PowerShell"s -gt operator to compare the two values.
#                 if ($smaller -and $larger) {
#                     $scriptblock = ([ScriptBlock]::Create("($larger) | Should $(if($NotGreater){'-Not '})-BeGreaterThan ($smaller)"))
#                     Write-Host $scriptblock
#                     It "$Title" $scriptblock
#                 }
#             }
#             Describe 'BeLessThan' {
#                 #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-BeLessThan] [<CommonParameters>]
#                 if ($smaller -and $larger) {
#                     $scriptblock = ([ScriptBlock]::Create("($smaller) | Should -BeLessThan ($larger)"))
#                     Write-Host $scriptblock
#                     It "$Title" $scriptblock
#                 }
#             }
#             Describe 'BeGreaterOrEqual' {
#                 #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-BeGreaterOrEqual] [<CommonParameters>]
#                 # Asserts that a number (or other comparable value) is greater than or equal to an expected value. Uses PowerShell"s -ge operator to compare the two values.
#                 if ($smaller -and $larger) {
#                     $scriptblock = ([ScriptBlock]::Create("($larger) | Should $(if($NotGreater){'-Not '})-BeGreaterOrEqual ($smaller)"))
#                     Write-Host $scriptblock
#                     It "$Title" $scriptblock
#                 }
#                 if ($_ordered) {
#                     if ($obj) {
#                         $scriptblock = ([ScriptBlock]::Create("($obj) | Should -BeGreaterOrEqual ($obj)"))
#                         Write-Host $scriptblock
#                         It "$Title" $scriptblock
#                     }
#                     if ($obj -and $equal_two) {
#                         $scriptblock = ([ScriptBlock]::Create("($obj) | Should -BeGreaterOrEqual ($equal_two)"))
#                         Write-Host $scriptblock
#                         It "$Title" $scriptblock
#                     }
          
#                 }
#             }
#             Describe 'BeLessOrEqual' {
#                 #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-BeLessOrEqual] [<CommonParameters>]
#                 # Asserts that a number (or other comparable value) is lower than, or equal to an expected value. Uses PowerShell"s -le operator to compare the two values.
#                 if ($smaller -and $larger) {
#                     $scriptblock = ([ScriptBlock]::Create("($smaller) | Should $(if($NotGreater){'-Not '})-BeLessOrEqual ($larger)"))
#                     Write-Host $scriptblock
#                     It "$Title" $scriptblock
#                 }
#                 if ($_ordered) {
#                     if ($obj) {
#                         $scriptblock = ([ScriptBlock]::Create("($obj) | Should -BeLessOrEqual ($obj)"))
#                         Write-Host $scriptblock
#                         It "$Title" $scriptblock
#                     }
#                     if ($obj -and $equal_two) {
#                         $scriptblock = ([ScriptBlock]::Create("($obj) | Should -BeLessOrEqual ($equal_two)"))
#                         Write-Host $scriptblock
#                         It "$Title" $scriptblock
#                     }
#                 }
#             }

#         }
#     }
#     Describe 'Container Operations' -ForEach (   $collections     ) {
#         Describe 'BeIn' {
#             #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-BeIn] [<CommonParameters>]
#             # Asserts that a collection of values contain a specific value. Uses PowerShell's -contains operator to confirm.
#             try {
#                 $not_contain = Get-Variable _not_contain -ValueOnly -ErrorAction Stop
#                 $not_contain | ForEach-Object {
#                     $scriptblock = ([ScriptBlock]::Create("($_) | Should -Not -BeIn ($obj)"))
#                     Write-Host $scriptblock
#                     It "$Title" $scriptblock
#                 }
#             }
#             catch {}  
#             try {
#                 $contain = Get-Variable _contain -ValueOnly -ErrorAction Stop
#                 $contain | ForEach-Object {
#                     $scriptblock = ([ScriptBlock]::Create("($_) | Should -BeIn ($obj)"))
#                     Write-Host $scriptblock
#                     It "$Title" $scriptblock
#                 }
#             }
#             catch {}  
#         }


#         Describe 'Contain' {
#             #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-Contain] [<CommonParameters>]
#             # Asserts that collection contains a specific value. Uses PowerShell's -contains operator to confirm.
#             try {
#                 $not_contain = Get-Variable _not_contain -ValueOnly -ErrorAction Stop
#                 $not_contain | ForEach-Object {
#                     $scriptblock = ([ScriptBlock]::Create("($obj) | Should -Not -Contain ($_)"))
#                     Write-Host $scriptblock
#                     It "$Title" $scriptblock
#                 }
#             }
#             catch {}  
#             try {
#                 $contain = Get-Variable _contain -ValueOnly -ErrorAction Stop
#                 $contain | ForEach-Object {
#                     $scriptblock = ([ScriptBlock]::Create("($obj) | Should -Contain ($_)"))
#                     Write-Host $scriptblock
#                     It "$Title" $scriptblock
#                 }
#             }
#             catch {}  
#         }
#         Describe 'HaveCount' {
#             #? Should [[-ActualValue] <Object>] [-Not] [-ExpectedValue <Object>] [-Because <Object>] [-HaveCount] [<CommonParameters>]
#             # Asserts that a collection has the expected amount of items.
#             #     It 'Should pass if collection has expected count' {
#             #         $collection = 1, 2, 3, 4, 5
#             #         $collection | Should -HaveCount 5
#             #     }

#             #     It 'Should fail if collection does not have expected count' {
#             #         $collection = 1, 2, 3, 4, 5
#             #         $collection | Should -Not -HaveCount 10
#             #     }
 
#             # }
#         }
#     }
#     Describe 'File Operations' {
#         Describe 'Exist' {
#             #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-Exist] [<CommonParameters>]
#             # Does not perform any comparison, but checks if the object calling Exist is present in a PS Provider. The object must have valid path syntax. It essentially must pass a Test-Path call.
#         }
#         Describe 'FileContentMatch' {
#             #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-FileContentMatch] [-ExpectedContent <Object>] [<CommonParameters>]
 
#         }

#         Describe 'FileContentMatchExactly' {
#             #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-ExpectedContent <Object>] [-FileContentMatchExactly] [<CommonParameters>]
 
#         }

#         Describe 'FileContentMatchMultiline' {
#             #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-ExpectedContent <Object>] [-FileContentMatchMultiline] [<CommonParameters>]
 
#         }

#         Describe 'FileContentMatchMultilineExactly' {
#             #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-ExpectedContent <Object>] [-FileContentMatchMultilineExactly] [<CommonParameters>]
 
#         }
#     }
#     Describe 'Function Operations' {
#         Describe 'HaveParameter' {
#             #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-HaveParameter] [-ParameterName <Object>] [-Type <Object>] [-DefaultValue <Object>] [-Mandatory] [-InParameterSet <Object>] [-HasArgumentCompleter] [-Alias <Object>] [<CommonParameters>]
 
#         }
#         Describe 'Throw' {
#             #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-Throw] [-ExpectedMessage <Object>] [-ErrorId <Object>] [-ExceptionType <Object>] [-PassThru] [<CommonParameters>]
 
#         }

#         Describe 'InvokeVerifiable' {
#             #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-InvokeVerifiable] [<CommonParameters>]
 
#         }

#         Describe 'Invoke' {
#             #? Should [[-ActualValue] <Object>] [-Not] [-Because <Object>] [-Invoke] [-CommandName <Object>] [-Times <Object>] [-ParameterFilter <Object>] [-ExclusiveFilter <Object>] [-ModuleName <Object>] [-Scope <Object>] [-Exactly] [-CallerSessionState <Object>] [<CommonParameters>] [<CommonParameters>]
 
#         }
#     }
# }
