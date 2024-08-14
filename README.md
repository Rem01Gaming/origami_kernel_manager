# Origami Kernel Manager

![Hero image for Origami Kernel Manager](.assets/hero_img.jpg)

---

Yet another kernel manager.

[![License](https://img.shields.io/badge/GNU-white?style=for-the-badge&logo=andela&logoColor=white&label=License&labelColor=222)](./LICENSE)
[![Latest release](https://img.shields.io/github/v/release/rem01gaming/origami_kernel_manager?label=Release&style=for-the-badge&logo=github&logoColor=white&labelColor=222)](https://github.com/rem01gaming/origami_kernel_manager/releases/latest)
[![Channel](https://img.shields.io/badge/Follow-Telegram-white.svg?style=for-the-badge&logo=telegram&logoColor=white&labelColor=222)](https://t.me/rem01schannel)
[![Download count](https://img.shields.io/github/downloads/rem01gaming/origami_kernel_manager/total?style=for-the-badge&logoColor=white&labelColor=222)](https://github.com/Rem01Gaming/origami_kernel_manager/releases)
[![Saweria](https://img.shields.io/badge/donate-white?style=for-the-badge&logo=iconjar&logoColor=white&label=Saweria&labelColor=222)](https://saweria.co/Rem01Gaming)
[![Buymeacoffee](https://img.shields.io/badge/donate-white?style=for-the-badge&logo=buy-me-a-coffee&logoColor=white&label=Buymeacoffee&labelColor=222)](https://www.buymeacoffee.com/Rem01Gaming)

## About 

Origami Kernel Manager is a set of utilities for power users to tune, adjust, and manage the kernel parameters through the command line interface (CLI), specifically on termux. It aims to deliver a comprehensive solution for enhancing device performance and customization by providing various settings for kernel fine-tuning.

## Why need a kernel manager? 

- Performance Optimization
  - Fine-tune CPU frequencies, governor profiles, and memory management for enhanced system performance.

- Battery Life Improvement
  - Optimize power-related settings to extend battery life by efficiently managing CPU power, power-saving features, and charging control.

- Customization and Features
  - Customize additional features on kernel that not available in your settings, such as display color calibration, Selinux, low memory killer, or advanced network settings.

- Stability and Reliability
  - Switch between different configurations to find a balance between performance and stability, ideal for users experimenting with kernel stuff.

## Features 
```yaml
Everything you might expect from a kernel manager, in addition to the following:
```

- Changing CPU Governor and frequencies
- CPU Core control
- CPU Frequencies settings for Mediatek devices via PPM and specific Kernel patch
- GPU Control for Mediatek, Snapdragon, Nvidia Tegra, Mali (in common), Google Tensor, Unisoc, Samsung, and other devices.
- DRAM Control for Mediatek and Snapdragon devices (Snapdragon has full CPU Bus settings)
- CPU Voltage offset for Mediatek
- Networking settings, such as TCP Congestion algorithm, SYN Cookies, TCP ECN, TCP Fastopen, etc.
- Display color calibration, including Mediatek's VideoX Livedisplay and Snapdragon's KCAL
- Memory parameters setting
- Scheduler Settings
- DT2W Settings, Touchpanel settings for oplus devices
- Idle Charging
- Mediatek tailored features such as APUs frequency, Performance and Power Management, Power Budget Management and more
- Apply previous settings (simlar with apply-on-boot but instead will applied on first open)

## Usage

- [Installation Guide](https://github.com/Rem01Gaming/origami_kernel_manager/wiki/Home)
- [Utility Documentation](https://github.com/Rem01Gaming/origami_kernel_manager/wiki/Utility-Documentation)

## License

This project is licensed under the GNU General Public License v3.0 or later. Refer to the [LICENSE](/LICENSE) file for detailed licensing information.

## WARNING 

The author assumes no responsibility under anything that might break due to the use/misuse of this software. By choosing to use/misuse it, you agree to do so at your own risk!

### CPU Voltage Offset warning for Mediatek devices

This feature can causes system instability, crashes and even FRY your CPU. We given limit up to 50+- ticks (312.5 mV) for this reason, don't mess with this setting too much.

### Charging controller warning

One of feature of Origami Kernel Manager, Charging controller manipulates Android low level (kernel) parameters which control the charging circuitry. Some devices, notably from Xiaomi (e.g., Poco X3 Pro), have a faulty PMIC (Power Management Integrated Circuit) that can be triggered by Charging controller feature. The issue blocks charging. Ensure the battery does not discharge too low.

Refer to [this XDA post](https://xdaforums.com/t/rom-official-arrowos-11-0-android-11-0-vayu-bhima.4267263/page-14#post-85119331) for additional details.

[lybxlpsv](https://github.com/lybxlpsv) suggests booting into bootloader/fastboot and then back into system to reset the PMIC.

