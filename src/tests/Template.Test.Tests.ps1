param(
    [string]$Param = 'Default Parameter'
)
BeforeDiscovery {
    # Code
}
BeforeAll {
    # Code
    # Import-Module
}
AfterAll {
    # Code
    # Remove-Module
}
Describe 'a Top level description' -Tag 'ParentTag' -ForEach $PSBoundParameters {
    BeforeAll {
        # Code
    }
    BeforeEach {
        # Code
    }
    AfterEach {
        # Code
    }
    AfterAll {
        # Code
    }
    It 'It block description' -Tag 'TestTag' {
        # Code
        # Assertion example:
        $Param | Should -Not -BeNullOrEmpty
    }
    Context 'Nested context description' -Tag 'TestTag' {
        It 'Test inside inner context' {
            # Code
        }
    }
    Describe 'Nested describe description' -Tag 'TestTag' {
        It 'Test inside inner describe' {
            # Code
        }
    }
}