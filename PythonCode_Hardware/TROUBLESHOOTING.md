# Hardware Integration & Troubleshooting Report

## 1. Executive Summary

An 8-channel proximity and ambient light sensing matrix was built using an **Adafruit Feather RP2350**, a **TCA9548A 8-Channel I2C Multiplexer**, and **eight VCNL4030 sensors** connected with STEMMA QT cables (see `Screenshot 2026-07-02 at 10.32.32 AM.png`).

During initial assembly, connecting the hardware components caused the system to freeze completely, dropping the USB Serial Monitor connection in Mu Editor. Through systematic hardware decoupling and low-level communication debugging, the conflict was isolated to an electrical timing fault on the microcontroller's I2C peripheral. The issue was resolved by moving the I2C bus to a software-driven implementation, enabling a stable 8-channel USB MIDI controller for Logic Pro.

## 2. Problem Description & Root Cause Analysis

### Symptoms

- Individual components worked correctly when tested on their own.
- When chained together, the system locked up instantly on boot.
- The Mu Editor Serial Monitor dropped its connection or threw an unhandled `OSError: [Errno 116] ETIMEDOUT`.

### Root Causes

1. **Pull-up resistor overload:** Every board in the chain has its own 10 kΩ pull-up resistors on the I2C signal lines (SDA and SCL). With multiple boards connected in parallel, the combined resistance dropped too low, making the electrical "pull" on the lines too strong for standard configurations to handle cleanly.
2. **Strict microcontroller timing:** The Raspberry Pi RP2350 enforces a rigid hardware state-machine timing profile for its internal I2C peripherals. Because the overloaded pull-ups distorted the voltage rise and fall times, the RP2350 flagged the bus as unstable or shorted.
3. **USB stack crash:** CircuitPython handles USB communication (Serial Monitor/REPL) on the same core processing layer, so the hard lock of the I2C peripheral crashed the USB stack and disconnected the board from the computer before an error message could be printed.

## 3. The Solution

The problem was resolved in three phases.

### Phase 1: Communication Layer Re-engineering

To bypass the RP2350's strict hardware timing, the bus was switched from the native hardware peripheral (`board.STEMMA_I2C()`) to software bit-banging (`bitbangio`).

- The bus frequency was lowered from the default **400 kHz** to **50 kHz**.
- The slower software bus gave the signals enough time to fully transition between high and low states, eliminating the `ETIMEDOUT` errors and giving a stable, crash-free connection to the Mu Serial Monitor.

### Phase 2: USB Framework Reconfiguration

To turn the stable sensor array into a musical controller, a custom `boot.py` was added to adjust the USB profile:

- Enabled MIDI at boot with `usb_midi.enable()`.
- Disabled unused Human Interface Devices with `usb_hid.disable()` to free up USB endpoints, so macOS recognizes the Feather RP2350 as a class-compliant MIDI instrument rather than a standard storage drive.

### Phase 3: Signal Mapping & Software Deployment

The firmware (`code.py`) continuously scans the multiplexer channels without freezing. It compares the raw proximity values against a threshold (`TRIGGER_THRESHOLD = 300`) and converts hand gestures into debounced **MIDI Note On / Note Off messages (notes 60–67)**. These are streamed live to Logic Pro over **USB MIDI Channel 1**, creating a contact-free performance controller.
