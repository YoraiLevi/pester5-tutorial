Describe 'Empty array contains null??' {
    # ModuleType Version    PreRelease Name                                PSEdition ExportedCommands
    # ---------- -------    ---------- ----                                --------- ----------------
    # Script     5.5.0                 Pester                              Desk      {Invoke-Pester, Describe, Context, It…} 
    It 'Piped BeIn' {
        # https://github.com/pester/Pester/blob/acc66a965219a8e70981977289227a211af4c70e/src/functions/assertions/BeIn.ps1#L12
        $null | Should -Not -BeIn @() 
        
    }
    It 'Piped Contain' {
        # https://github.com/pester/Pester/blob/acc66a965219a8e70981977289227a211af4c70e/src/functions/assertions/Contain.ps1#L12
        @() | Should -Contain $null
        # Expected $null to not be found in collection $null, but it was found.
    }
    It 'No pipe Contain' {
        Should @() -Not -Contain $null
    }
    It 'Sanity?' {
        @() -contains $null | Should -BeFalse
        $null -contains @() | Should -BeFalse
        $null -contains $null | Should -BeTrue
    }
    It 'Be' {
        @($null) | Should -Be @($null)
    }
}