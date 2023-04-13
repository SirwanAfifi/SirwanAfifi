

Function Get-Posts {
    Param (
        [Parameter(Mandatory = $false)]
        [string]$rssUrl
    )
    $posts = @()
    $feed = [xml](Invoke-WebRequest -Uri $rssUrl).Content
    $feed.rss.channel.item | Select-Object -First 3 | ForEach-Object {
        $post = [PSCustomObject]@{
            Title       = $_.title."#cdata-section" ?? $_.title
            Link        = $_.link
            Description = $_.description."#cdata-section" ?? $_.description
            PubDate     = $_.pubDate
        }
        $posts += $post
    }
    $posts
}

Function Get-DntipsPosts {
    $assemblyPath = "$(Get-Location)/deps/CodeHollow.FeedReader.dll"
    [Reflection.Assembly]::LoadFile($assemblyPath)
    $feed = [CodeHollow.FeedReader.FeedReader]::ReadAsync("https://www.dntips.ir/feed/author/%d8%b3%db%8c%d8%b1%d9%88%d8%a7%d9%86%20%d8%b9%d9%81%db%8c%d9%81%db%8c").Result
    $posts = @()
    $feed.Items | Select-Object -First 3 | ForEach-Object {
        $post = [PSCustomObject]@{
            Title       = $_.Title
            Link        = $_.Link
            Description = $_.Description
            PubDate     = $_.PublishingDate
        }
        $posts += $post
    }
    $posts
}

Function Set-Posts {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject[]]$posts,
        [Parameter(Mandatory = $false)]
        [string]$marker = "## Recent Blog Posts - English"
    )
    Begin {
        $readMePath = "./README.md"
        $readmeContents = Get-Content -Path $readMePath -Raw
        $markdownTable = "| Link | Published At |`n"
        $markdownTable += "| --- | --- |`n"
    }
    Process {
        if ($null -eq $_.Title) {
            return
        }
        $date = Get-Date -Date $_.PubDate
        $link = "[$($_.Title)]($($_.Link))"
        
        $markdownTable += "| $($link) | $($date.ToString("dd/MM/yy")) |`n"
    }
    End {
        $updatedContent = $readmeContents -replace "$marker\n([\s\S]*?)(?=##| $)", "$marker`n$($markdownTable)`n"
        $updatedContent | Set-Content -Path $readMePath
    }
}

Function Set-Blogs {
    $recentBlogPostsStr = "## Recent blog posts -"
    Get-Posts("https://dev.to/feed/sirwanafifi") | Set-Posts -marker "$recentBlogPostsStr dev.to"
    Get-Posts("https://sirwan.info/rss.xml") | Set-Posts -marker "$recentBlogPostsStr sirwan.info"
    Get-DntipsPosts | Set-Posts -marker "$recentBlogPostsStr dntips.ir"
}

Set-Blogs

