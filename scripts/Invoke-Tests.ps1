# https://stackoverflow.com/questions/72219858/how-can-i-use-pester-v5-configuration-or-container-with-four-standard-arguments
# $container = New-PesterContainer -Path "..." -Data @{
#     customParamA= "value"; 
#     customParamB= "value"; 
# }

# $pesterConfig = [PesterConfiguration]@{
#     Run = @{
#         Exit = $true
#         Container = $container
#     }
#     Output = @{
#         Verbosity = 'Detailed'
#     }
#     TestResult = @{
#         Enabled      = $true
#         OutputFormat = "NUnitXml"
#         OutputPath   = $xmlpath
#     }
#     Should = @{
#         ErrorAction = 'Stop'
#     }
# }

Invoke-Pester# -Configuration $pesterConfig
# invoke-Pester -Output Diagnostic
# invoke-Pester -Output Detailed