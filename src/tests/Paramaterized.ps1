param(
    [Parameter(Mandatory)]
    $Param
)
BeforeDiscovery {
    # Gather initial values for generating tests
    $ExtraParam = 'value'
}
Describe 'Test Container' -ForEach @(@{Param = $Param; ExtraParam = $ExtraParam }) {
    BeforeAll {

    }
    BeforeEach {

    }
    AfterEach {

    }
    AfterAll {

    }
    It 'Test with value <Param>' {
        $Param | Should -Not -Be $null
        $ExtraParam | Should -Not -Be $null
    }
}