import usb_hid
import usb_midi

# Explicitly enable USB MIDI capabilities
usb_midi.enable()

# On some strict microcontrollers, disabling unused HID keys
# frees up the USB bandwidth needed for MIDI to broadcast
usb_hid.disable()
