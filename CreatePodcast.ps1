##### Dependencies
####
#### https://ffmpeg.org/ffmpeg.html
#### FFMPEG added to user path variable


# Check working path exist
if (!(Test-Path -Path "$($env:USERPROFILE)\Documents\Service\Recorded Messages")) {

    Write-Host -ForegroundColor Red "`nRECORDED MESSAGES FOLDER MISSING`nStopping Script"
    pause; exit
    
}

Write-Host -ForegroundColor Green "`nInitiating Intro/Message/Outro`n"
$path = "$($env:USERPROFILE)\Documents\Service\Recorded Messages"


# Check podcast intro file exist
if (!(Test-Path -Path "$($path)\Bumpers\Podcast Intro.wav")) {

    Write-Host -ForegroundColor Red "`nPODCAST INTRO FILE MISSING`nStopping Script"
    pause; exit

}

$intro = Get-Item -Path "$($path)\Bumpers\Podcast Intro.wav"


# Check podcast outro file exist
if (!(Test-Path -Path "$($path)\Bumpers\Podcast Outro.wav")) {

    Write-Host -ForegroundColor Red "`nPODCAST OUTRO FILE MISSING`nStopping Script"
    pause; exit
    
}

$outro = Get-Item -Path "$($path)\Bumpers\Podcast Outro.wav"


# Store latest message recording
$message = Get-Item -Path "$($path)\Video\*" -Include *.mkv,*.mp4 | Select-Object -Last 1
if ($message -eq $null) {

    Write-Host -ForegroundColor Red "`nMESSAGE NULL`nStopping Script"
    pause; exit

}

do {

    $input = Read-Host "Need to input a start/stop time for the latest message? (y/n)"

    if ($input -notin ('y','n','yes','no')) {

        Write-Host -ForegroundColor Yellow "Invalid input"

    }
    
    if ($input -in ('y','yes')) {

        # Gather length of video file in seconds
        $floor = [math]::Floor($(ffprobe.exe -i $message.FullName -show_entries format=duration -v quiet -of csv="p=0"))

        # Ask for start time but cannot be greater than the second to last second
        do {

            $startTime = Read-Host "Enter start time in seconds (Max seconds: $($floor - 1))"

        } while ($startTime -notin (0..$($floor - 1)))

        # Ask for stop time but has to be in range of start time input and end of video
        do {

            $stopTime = Read-Host "Enter stop time in seconds (Between: $($startTime) and $($floor))"

        } while ($stopTime -notin ($($startTime)..$($floor)))

    }

} while ($input -notin ('y','n','yes','no'))

Write-Host -ForegroundColor Green "`nConverting Message (This will take approximately 45-60 seconds)`n"

# Use start and stop time if input y,yes
if ($input -notin ('y','yes')) {

    ffmpeg.exe -i $message.FullName -hide_banner -b:a 320k -filter:a "volume=17dB" "$($path)\Audio\$($message.BaseName).mp3" *> $null

} else {

    ffmpeg.exe -i $message.FullName -hide_banner -ss $startTime -to $stopTime -b:a 320k -filter:a "volume=17dB" "$($path)\Audio\$($message.BaseName).mp3" *> $null

}

# Get object path
$messageF = Get-Item -Path "$($path)\Audio\$($message.BaseName).mp3"

Write-Host -ForegroundColor Green "`nProcessing podcast file (This will take approximately 45-60 seconds)`n"
ffmpeg.exe -i $intro.FullName -i $messageF.FullName -i $outro.FullName -b:a 320k -filter_complex "[0][1]acrossfade=d=7[a01];[a01][2]acrossfade=d=5" "$($path)\Podcasts\$($message.BaseName).mp3" *> $null
############## Path to file ####### Path to File ####### Path to File #Audio Bitrate ############ first 2 inputs crossfade # pipe [a01] and crossfade # output to file ############################# null output console
################################################################################################# 7 seconds and output to  # with [2] the thrid input
################################################################################################# [a01]                    # for 5 seconds