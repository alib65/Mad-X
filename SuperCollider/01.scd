// =====================================================================
// SuperCollider Acoustic Hang Drum (Handpan) Engine
// =====================================================================

s.boot; // 1. Boot the audio server first

(
// 2. Initialize MIDI inside SuperCollider
MIDIClient.init;
MIDIIn.connectAll;

// 3. Define the Physical Modeling Hang Drum Ring (Resonant Bandpass Model)
SynthDef(\hangDrum, {
	arg freq = 220, strikeBright = 0.2, amp = 0.6, pan = 0;
	var strikeEnv, ringEnv, excitation, strikeNoise, body, signal;

	// Strike transient (the moment the finger hits the steel)
	strikeEnv = EnvGen.kr(Env.perc(0.001, 0.01));
	strikeNoise = WhiteNoise.ar(amp) * strikeEnv;

	// Total ring decay envelope (Hang drums ring out naturally for quite a while)
	ringEnv = EnvGen.kr(Env.perc(0.005, 2.5), doneAction: 2);

	// The 'Ding' and 'Gu' acoustic properties:
	// Mixing a sharp strike burst with a ringing sinus-burst
	excitation = strikeNoise + (SinOsc.ar(freq * 2) * strikeEnv * strikeBright);

	// Multi-resonance physical modeling using a bank of tuned bandpass filters
	// This simulates the structural nodes of an authentic hammered steel handpan shell
	body = Klank.ar(
		`[
			[1, 2.0, 2.98, 4.02, 5.1],       // Fundamental and harmonic overtone nodes
			[1.0, 0.6, 0.4, 0.25, 0.15],     // Scale amplitudes of individual harmonics
			[2.2, 1.4, 0.9, 0.6, 0.3]        // Ring decays per frequency component
		],
		excitation,
		freqscale: freq
	);

	signal = body * ringEnv * 0.4;

	// Final acoustic smoothing
	signal = LPF.ar(signal, 3500);
	signal = Limiter.ar(signal, 0.95);

	Out.ar(0, Pan2.ar(signal, pan));
}).add;

// State Variables
~strikeStyle = 0.1;                 // Controlled dynamically by Sensor 7
~sensorTriggered = Array.fill(7, { False });

// Traditional D Minor Integral Handpan Tuning (Frequencies in Hz)
// Sensor 0 is the deep central "Ding" note.
~hangScale = [146.83, 220.00, 261.63, 293.66, 329.63, 349.23, 440.00]; // D3, A3, C4, D4, E4, F4, A4

// 4. Strike Style Controller: Sensor 7 (CC 27) alters striking brightness/timbre
MIDIFunc.cc({ |val|
	// Far away = Soft finger pad strike (low value). Close up = Hard knuckle ping (high value)
	~strikeStyle = val.linlin(0, 127, 0.05, 0.75);
}, ccNum: 27);

// 5. Individual Hang Drum Tone Triggers: Sensors 0-6 (CC 20-26)
7.do({ |i|
	MIDIFunc.cc({ |val, num|
		var sensorIndex = num - 20;
		var rawValue = val;

		if(rawValue > 45, {
			if(~sensorTriggered[sensorIndex] == False, {
				var targetFreq = ~hangScale[sensorIndex];

				if(sensorIndex == 0, {
					"Striking Central DING [D3 Root Note]".postln;
				}, {
					"Striking Handpan Tone Field % [ % Hz ]".format(sensorIndex, targetFreq.round(0.1)).postln;
				});

				Synth(\hangDrum, [
					\freq, targetFreq,
					\strikeBright, ~strikeStyle, // Modulated live by your left hand on Sensor 7
					\amp, 0.7,
					\pan, sensorIndex.linlin(0, 6, -0.6, 0.6) // Pan notes geometrically across the stereo image
				]);

				~sensorTriggered[sensorIndex] = True;
			});
		}, {
			if(rawValue < 30, {
				~sensorTriggered[sensorIndex] = False;
			});
		});
	}, ccNum: 20 + i);
});

"--- Acoustic Hang Drum Matrix Running ---".postln;
)