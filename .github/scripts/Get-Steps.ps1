Function Set-Steps {
    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSObject]$json
    )
    Write-Host ($json | ConvertTo-Json)
    $SvgPath = "$(Get-Location)/assets/step.svg"
    $SvgContent = Get-Content -Path $SvgPath -Raw
    $TextTags = @"
    <tspan id="step-count" font-weight="bold">$([System.String]::Format("{0:n0}", [int]$json.steps))</tspan>
"@
    $DatetimeTags = "<text id=""datetime"" x=""710"" y=""72"" font-size=""39"" fill=""#99989E"">$($json.date)</text>"
    $SvgContent = $SvgContent -Replace '<tspan id="step-count" font-weight="bold">.*?</tspan>', $TextTags
    $SvgContent = $SvgContent -Replace '<text id="datetime" x="710" y="72" font-size="39" fill="#99989E">.*?</text>', $DatetimeTags
    $SvgContent | Set-Content -Path $SvgPath
}

Function Get-LatestSteps {
    Try {
        $Uri = $env:STEPS_URI
        Write-Host "Uri: $Uri"
        
        # Set headers to match the Worker's expectations
        $headers = @{
            'Accept' = 'application/json'
            'Content-Type' = 'application/json'
        }

        # Make the request
        $response = Invoke-WebRequest -Uri "$Uri/steps" -Headers $headers -Method GET -UseBasicParsing
        
        if ($response.StatusCode -eq 200) {
            $JsonResult = $response.Content | ConvertFrom-Json
            Write-Host "Steps: $($JsonResult.steps)"
            Return $JsonResult
        } else {
            throw "Unexpected status code: $($response.StatusCode)"
        }
    }
    Catch {
        Write-Host "Error Details:"
        Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)"
        Write-Host "Status Description: $($_.Exception.Response.StatusDescription)"
        Write-Host "Message: $($_.Exception.Message)"
        
        Return @{
            steps = 0
            date  = Get-Date -Format "yyyy-MM-dd"
        }
    }
}

Write-Host "Getting latest steps..."
Get-LatestSteps | Set-Steps
Write-Host "Done!"
