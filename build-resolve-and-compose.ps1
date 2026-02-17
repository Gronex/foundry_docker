param(
    [string]$FinalImageName = "localhost/foundry-vtt",
    [string]$ComposeFile = "compose.yml",
    [string]$VersionsPath = "versions",
    [string]$InitialVersionArg = "latest"
)
$ErrorActionPreference = 'Stop'

function Version-GE {
    param([string]$a, [string]$b)
    # returns $true if a >= b using major.minor numeric compare; if b is null => true; if a invalid => $false
    if (-not ($a -match '^\s*(\d+)\.(\d+)\s*$')) { return $false }
    $majorA = [int]$Matches[1]; $minorA = [int]$Matches[2]

    if (-not $b) { return $true }
    if (-not ($b -match '^\s*(\d+)\.(\d+)\s*$')) { return $true }

    $majorB = [int]$Matches[1]; $minorB = [int]$Matches[2]

    if ($majorA -gt $majorB) { return $true }
    return ($minorA -ge $minorB)
}

function Resolve-Version {
    param(
        [string]$VersionArg = "latest",
        [string]$PathToVersions = "versions"
    )

    if (-not (Test-Path $PathToVersions -PathType Container)) {
        Write-Error "Versions path '$PathToVersions' not found."
        exit 1
    }

    if ($VersionArg -ne 'latest') {
        $file = Join-Path $PathToVersions "FoundryVTT-$VersionArg.zip"
        if (-not (Test-Path $file -PathType Leaf)) {
            Write-Error "Requested version file '$file' not found."
            exit 1
        }
        return $VersionArg
    }

    $best = $null
    Get-ChildItem -Path $PathToVersions -Filter 'FoundryVTT-*.zip' -File | ForEach-Object {
        $name = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
        $parts = $name -split '-'
        if ($parts.Length -lt 2) { return }
        $candidate = $parts[1]
        if (-not ($candidate -match '^\d+\.\d+$')) { return }
        if (-not $best) { $best = $candidate; return }
        if (Version-GE $candidate $best) { $best = $candidate }
    }

    if (-not $best) {
        Write-Error "No versions found in '$PathToVersions'."
        exit 1
    }

    return $best
}

# main
$resolved = Resolve-Version -VersionArg $InitialVersionArg -PathToVersions $VersionsPath
Write-Host "Resolved version: $resolved"

$fileName = "FoundryVTT-$resolved.zip"

$imageTag = "$($FinalImageName):$($resolved)"
podman image inspect $imageTag > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Image $imageTag not found, building..."
    podman build --build-arg ARTIFACT=$fileName --build-arg FOUNDRY_VERSION=$resolved --label "org.opencontainers.image.version=$resolved" -t $imageTag .
    if ($LASTEXITCODE -ne 0) {
        Write-Error "podman build failed."
        exit 1
    }
} else {
    Write-Host "Image $imageTag exists, skipping build."
}

# export VERSION for docker-compose and start services
$env:VERSION = $resolved
Write-Host "Starting podman compose with VERSION=$resolved ..."
podman compose -f $ComposeFile up -d --no-build
if ($LASTEXITCODE -ne 0) {
    Write-Error "podman compose up failed."
    exit 1
}

Write-Host "Done. Services started with VERSION=$resolved"