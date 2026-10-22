import time
import board
import bitbangio
import adafruit_tca9548a
import adafruit_vcnl4030
import usb_midi
import adafruit_midi
from adafruit_midi.control_change import ControlChange

# Initialize stable software I2C bus at 50kHz (Bypassing RP2350 hardware lockup)
i2c = bitbangio.I2C(board.SCL, board.SDA, frequency=50000)
tca = adafruit_tca9548a.TCA9548A(i2c)
midi = adafruit_midi.MIDI(midi_out=usb_midi.ports[1], out_channel=0)

CC_CHANNELS = [20, 21, 22, 23, 24, 25, 26, 27]
prev_values = [-1] * 8

# --- CALIBRATION VARIABLES ---
# Adjust these based on what the sensors actually read through your case
PROX_MIN = 150   # Raw value at 30cm (baseline reflection of the case + distant object)
PROX_MAX = 4000  # Raw value just outside the case (>5mm away)

print("Atmosphere Sensor Array Streaming Continuous Data...")

while True:
    for i in range(8):
        try:
            prox = adafruit_vcnl4030.VCNL4030(tca[i]).proximity

            # UNCOMMENT THIS LINE TEMPORARILY TO CALIBRATE:
            # print("Sensor", i, "Raw:", prox)

            # 1. Clamp the raw reading to ignore anything outside our target physical space
            clamped_prox = max(PROX_MIN, min(PROX_MAX, prox))

            # 2. Map the clamped value linearly to MIDI 0-127
            val = int(((clamped_prox - PROX_MIN) / (PROX_MAX - PROX_MIN)) * 127)

            if val != prev_values[i]:
                midi.send(ControlChange(CC_CHANNELS[i], val))
                prev_values[i] = val
        except (ValueError, OSError):
            pass

    time.sleep(0.005)# Write your code here :-)
