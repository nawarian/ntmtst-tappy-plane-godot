#!/bin/bash

# optimise SFX files
mkdir -p sfx/optimised
for file in sfx/*.wav; do
  out_file="sfx/optimised/$(basename "${file%.wav}.mp3")"
  ffmpeg -y -i "$file" -b:a 64k "$out_file"
done

# optimise BGM files
mkdir -p bgm/optimised
for file in bgm/*.mp3; do
  out_file="bgm/optimised/$(basename "$file")"
  ffmpeg -y -i "$file" -b:a 64k "$out_file"
done
