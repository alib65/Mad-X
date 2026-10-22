(
s.waitForBoot({
    "Waking up the Monolithic Drone Engine...".postln;

    MIDIClient.init;
    MIDIIn.connectAll;

    SynthDef(\monolithEngine, {
        arg prox0=0, prox1=0, prox2=0, prox3=0, prox4=0, prox5=0, prox6=0, prox7=0;
        var tone0, tone1, tone2, tone3, dynamicChord, qualityFilter, stereoSpread, cavernReverb;

        // --- 1. SOUND GENERATION LAYER (Sensors 0-3 as Direct Volume Faders) ---
        // Each sensor acts as a smooth volume fader for a specific cinematic interval
        tone0 = Saw.ar(55) * Lag.kr(linlin(prox0, 0, 127, 0, 0.4), 0.1);     // Deep Root (A1)
        tone1 = Saw.ar(110) * Lag.kr(linlin(prox1, 0, 127, 0, 0.35), 0.1);   // Octave Up (A2)
        tone2 = Saw.ar(130.81) * Lag.kr(linlin(prox2, 0, 127, 0, 0.35), 0.1); // Minor 3rd (C3)
        tone3 = Saw.ar(164.81) * Lag.kr(linlin(prox3, 0, 127, 0, 0.35), 0.1); // Perfect 5th (E3)

        // Combine the generation tones into a single dense stereo wave
        dynamicChord = Splay.ar([tone0, tone1, tone2, tone3]);

        // --- 2. QUALITY MODIFIER LAYER (Sensors 4-7) ---
        // Sensor 4: Aggressive low-pass filter sweep (Muffled to screaming bright)
        qualityFilter = Lag.kr(linlin(prox4, 0, 127, 200, 8000), 0.1);
        dynamicChord = MoogFF.ar(dynamicChord, qualityFilter.asAudioRateInput, gain: 1.5);

        // Sensor 5: High-frequency tearing distortion (Adds edge and harmonics)
        dynamicChord = (dynamicChord * linlin(prox5, 0, 127, 1.0, 4.0)).distort;

        // Sensor 6: Thick detune chorus effect (Widens the wall of sound)
        stereoSpread = DelayC.ar(dynamicChord, 0.05, SinOsc.kr(0.2 + (prox6 * 0.05)).range(0.01, 0.03));
        dynamicChord = Mix([dynamicChord, stereoSpread * 0.5]);

        // Sensor 7: Giant Space Echo / Reverb wash
        cavernReverb = GVerb.ar(dynamicChord, roomsize: 200, revtime: 3, drylevel: 0) * linlin(prox7, 0, 127, 0, 0.6);
        dynamicChord = dynamicChord + cavernReverb;

        // Output with brick-wall peak limiter protection
        Out.ar(0, Limiter.ar(dynamicChord * 1.5, 0.95));
    }).add;

    s.sync;

    // Boot the monolithic instrument directly into memory
    ~droneNode = Synth(\monolithEngine);

    MIDIdef.freeAll;

    MIDIdef.cc(\matrixDataIn, { |val, num, chan, src|
        var paramSymbol, gatedValue;

        // Universal hardware noise gate: cuts baseline sensor jitter completely
        gatedValue = if(val <= 10, { 0 }, { val });

        paramSymbol = ("prox" ++ (num - 20)).asSymbol;
        ~droneNode.set(paramSymbol, gatedValue);
    }, ccNum: (20..27));

    "Monolith active. Wield the sound wall directly.".postln;
});
)