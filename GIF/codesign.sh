#!/bin/bash

cert="3rd Party Mac Developer Application: zhang  xi (54TGPDSGF2)"

codesign -f -s "$cert" --entitlements ./ffmpeg.entitlements ./ffmpeg
codesign -f -s "$cert" --entitlements ./ffmpeg.entitlements ./ffprobe
codesign -f -s "$cert" --entitlements ./ffmpeg.entitlements ./gifsicle

