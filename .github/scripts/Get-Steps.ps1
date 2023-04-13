Function Set-Steps {
    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSObject]$json
    )
    $SvgPath = "$(Get-Location)/assets/step.svg"
    $SvgContent = Get-Content -Path $SvgPath -Raw
    $TextTags = @"
    <tspan id="step-count" font-weight="bold">$([System.String]::Format("{0:n0}", [int]$json.steps))</tspan>
"@
    $DatetimeTags = "<text id=""datetime"" x=""800"" y=""72"" font-size=""39"" fill=""#99989E"">$($json.date)</text>"
    $SvgContent = $SvgContent -Replace '<tspan id="step-count" font-weight="bold">.*?</tspan>', $TextTags
    $SvgContent = $SvgContent -Replace '<text id="datetime" x="800" y="72" font-size="39" fill="#99989E">.*?</text>', $DatetimeTags
    $SvgContent | Set-Content -Path $SvgPath
}

Function Get-LatestSteps {
    Try {
        $Uri = $env:STEPS_URI
        $JsonResult = (Invoke-WebRequest -Uri $Uri).Content | ConvertFrom-Json
        Return $JsonResult
    }
    Catch {
        Return @{
            steps = 0
            date  = Get-Date -Format "yyyy-MM-dd"
        }
    }
}

Get-LatestSteps | Set-Steps