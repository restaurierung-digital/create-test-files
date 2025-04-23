# Create sample images with Powershell and ImageMagick
# The file name consists of a consecutive number, a prefix and/or suffix can be added
#
# To use the script ImageMagick <https://imagemagick.org/> must be available
#
# Date: 2025-02-25 | Version 1.0

# Functions
function print-error-end {
	[CmdletBinding()]
	param(
		[Parameter()]
		[string]$error_message = "Unknown error"
	)

	Write-Host -ForegroundColor White -BackgroundColor Red "ERROR: $error_message"
	exit
}

# Welcome Message
Write-Host "Create sample images"

# Check for ImageMagick
try {
	magick identify --version | Out-Null
} catch {
    print-error-end -error_message "Imagemagick is not available"
}

# Prompt for the destination path
$outputPath = Read-Host -Prompt "Destination path for the images"
if (-Not (Test-Path -Path "$outputPath")) { print-error-end -error_message "Path not found" }

# Prompt for the number of files
$fileCount = Read-Host -Prompt "Enter the number of files to be created"
if ($fileCount -match "^[1-9]\d*$") {
	$fileCount = [int]$fileCount
} else {
	print-error-end -error_message "Not a positive whole number"
}

# Prompt for image width
$imageWidth = Read-Host -Prompt "Image width (default: 100)"
if ([string]::IsNullOrEmpty($imageWidth)) { $imageWidth = 100 }
if ($imageWidth -match "^[1-9]\d*$") {
	$imageWidth = [int]$imageWidth
} else {
	print-error-end -error_message "Not a positive whole number"
}

# Prompt for image height
$imageHeight = Read-Host -Prompt "Image height (default: 100)"
if ([string]::IsNullOrEmpty($imageHeight)) { $imageHeight = 100 }
if ($imageHeight -match "^[1-9]\d*$") {
	$imageHeight = [int]$imageHeight
} else {
	print-error-end -error_message "Not a positive whole number"
}

# Prompt for image file type
$compatibleFileTypes = "tif","png","gif","jpg"
$fileType = Read-Host -Prompt "File type (tif, png, gif, jpg) (default: png)"
if ([string]::IsNullOrEmpty($fileType)) { $fileType = "png" }
if ($compatibleFileTypes.contains($fileType.toLower())) {
	$fileType = [string]$fileType
} else {
	print-error-end -error_message "Not a compatible file type"
}

# Prompt for prefix
$filenamePrefix = Read-Host -Prompt "File name prefix (can be empty)"
$filenamePrefix = $filenamePrefix.Trim()
if (-Not [string]::IsNullOrEmpty($filenamePrefix)) {
	if (-Not (Test-Path -IsValid "$filenamePrefix")) { print-error-end -error_message "Not a valid file name prefix" }
}

# Prompt for suffix
$filenameSuffix = Read-Host -Prompt "File name suffix (can be empty)"
$filenameSuffix = $filenameSuffix.Trim()
if (-Not [string]::IsNullOrEmpty($filenameSuffix)) {
	if (-Not (Test-Path -IsValid "$filenameSuffix")) { print-error-end -error_message "Not a valid file name prefix" }
}

# Get length of fileCount
$countLength = $fileCount.tostring().length

# Create images
for ($i = 1; $i -le $fileCount; $i++) {
	$paddedNumber = $i.ToString().PadLeft($countLength, '0')
	Write-Host "$filenamePrefix$paddedNumber$filenameSuffix.$fileType"
	$magickCommand = "magick -size $imageWidth" + "x" + "$imageHeight! -gravity center label:$paddedNumber `"$outputPath\$filenamePrefix$paddedNumber$filenameSuffix.$fileType`""
	Invoke-Expression $magickCommand
}

# Finish
if ($fileCount -eq 1)
{
	Write-Host "The image was created"
} else {
	Write-Host "$fileCount images were created"
}
