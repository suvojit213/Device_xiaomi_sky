echo "Cloning Basic Call recorder..."

# BCR
git clone https://github.com/suvojit213/vendor_bcr.git vendor/bcr

echo "done"

#!/bin/bash
#2by2 Vendor Setup Script
echo "Setting up repositories for Redmi 12 5G / Poco M6 Pro 5G (sky)..."

# Clone the kernel source
echo "Cloning kernel repository..."
git clone https://github.com/PixelOS-Devices/device_xiaomi_sky-kernel.git device/xiaomi/sky-kernel

# Clone the vendor source
echo "Cloning vendor repository..."
git clone https://github.com/dhanush281/vendor_xiaomi_sky.git vendor/xiaomi/sky

# Clone the hardware repository
echo "Cloning hardware repository..."
git clone https://github.com/PixelOS-AOSP/hardware_xiaomi.git hardware/xiaomi

# Clone the agm repository
echo "cloning agm repository..."
rm -rf hardware/qcom-caf/sm8450/audio/agm && git clone https://github.com/dhanush281/agm.git hardware/qcom-caf/sm8450/audio/agm 
echo "Setup complete. Repositories are ready."

echo "Completed, proceeding to lunch"
