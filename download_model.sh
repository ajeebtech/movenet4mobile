#!/bin/bash

# Download MoveNet SinglePose Lightning model
# This script downloads the TensorFlow Lite model for MoveNet

MODEL_URL="https://tfhub.dev/google/lite-model/movenet/singlepose/lightning/tflite/int8/4?lite-format=tflite"
MODEL_FILE="movenet_singlepose_lightning.tflite"

echo "Downloading MoveNet SinglePose Lightning model..."
echo "URL: $MODEL_URL"

curl -L "$MODEL_URL" -o "$MODEL_FILE"

if [ -f "$MODEL_FILE" ]; then
    echo "✅ Model downloaded successfully: $MODEL_FILE"
    echo "File size: $(ls -lh $MODEL_FILE | awk '{print $5}')"
    echo ""
    echo "Next steps:"
    echo "1. Add this file to your Xcode project"
    echo "2. Make sure to check 'Copy items if needed' when adding"
    echo "3. Ensure the file is added to your app target"
else
    echo "❌ Failed to download model"
    exit 1
fi

