(
s.waitForBoot({
    "Summoning the Microtonal Brass Resonance Matrix...".postln;

    MIDIClient.init;
    MIDIIn.connectAll;

    SynthDef(\rainEngine, {
        arg prox0=0, prox1=0, prox2=0, prox3=0, prox4=0, prox5=0, prox6=0, prox7=0;
        var s0, s1, s2, s3, s4, s5, s6, s7;
        var trig0, trig1, trig2, trig3;
        var voice0, voice1, voice2, voice3;
        var combinedAcoustics, hornGrowl, metalBodyResonance, phaseChorusing, spatialStereo;
        var baseFreq, ratio1, ratio2, ratio3;

        // --- 0. HIGH-ACCURACY INPUT SMOOTHING ---
        s0 = Lag3.kr(Ramp.kr(prox0, 0.05), 0.18);
        s1 = Lag3.kr(Ramp.kr(prox1, 0.05), 0.18);
        s2 = Lag3.kr(Ramp.kr(prox2, 0.05), 0.18);
        s3 = Lag3.kr(Ramp.kr(prox3, 0.05), 0.18);
        s4 = Lag3.kr(Ramp.kr(prox4, 0.05), 0.18);
        s5 = Lag3.kr(Ramp.kr(prox5, 0.05), 0.18);
        s6 = Lag3.kr(Ramp.kr(prox6, 0.05), 0.18);
        s7 = Lag3.kr(Ramp.kr(prox7, 0.05), 0.18);

        // Microtonal Just Intonation Matrix tuning definitions
        baseFreq = 110;               // Low Root A
        ratio1   = baseFreq * (9/8);  // Microtonal Major Second (123.75 Hz)
        ratio2   = baseFreq * (11/8); // Undecimal Super-Fourth (151.25 Hz)
        ratio3   = baseFreq * (13/8); // Tridecimal Neutral Sixth (178.75 Hz)

        // --- 1. MICROTONAL BRASS GENERATION (Sensors 0-3) ---

        // SENSOR 0: Deep Sub-Bass Tuba / Drone
        trig0 = Dust.ar(linlin(s0, 0, 127, 0, 30));
        voice0 = MoogFF.ar(
            Pulse.ar([baseFreq, baseFreq * 0.99], 0.3) * Decay2.ar(trig0, 0.05, 0.8),
            linlin(s0, 0, 127, 150, 1200), // Sensor height drives brass brightness
            1.2
        ) * 16.0;

        // SENSOR 1: Microtonal Tenor Horn (Rich, complex pulse waves)
        trig1 = Dust.ar(linlin(s1, 0, 127, 0, 35));
        voice1 = MoogFF.ar(
            Pulse.ar([ratio1, ratio1 * 1.015], 0.4) * Decay2.ar(trig1, 0.02, 0.5),
            linlin(s1, 0, 127, 300, 2800),
            0.8
        ) * 12.0;

        // SENSOR 2: High Harmonics Trombone Glint (Piercing 11/8 overtone cluster)
        trig2 = Dust.ar(linlin(s2, 0, 127, 0, 25));
        voice2 = Formlet.ar(
            LFPar.ar([ratio2, ratio2 * 0.985]) * Decay.ar(trig2, 0.15),
            linlin(s2, 0, 127, 800, 3500),
            0.002,
            0.04
        ) * 22.0;

        // SENSOR 3: Screaming Trumpet Fanfare Bell (Extreme 13/8 microtonal piercing tone)
        trig3 = Dust.ar(linlin(s3, 0, 127, 0, 20));
        voice3 = MoogFF.ar(
            Saw.ar([ratio3, ratio3 * 1.008]) * Decay2.ar(trig3, 0.01, 0.3),
            linlin(s3, 0, 127, 1200, 6000),
            1.4
        ) * 26.0;

        // Combine the raw brass elements together
        combinedAcoustics = voice0 + voice1 + voice2 + voice3;

        // --- 2. EXPERIMENTAL HORN MODIFIERS (Sensors 4-7) ---

        // Sensor 4: Harmonic Growl & Flutter-Tongue Drive
        hornGrowl = combinedAcoustics * SinOsc.ar(LFNoise2.kr(12).range(35, 120));
        hornGrowl = (hornGrowl * linlin(s4, 0, 127, 1.0, 3.5)).distort; // Adds warm saturated bite
        combinedAcoustics = SelectX.ar(linlin(s4, 0, 127, 0.0, 0.75), [combinedAcoustics, hornGrowl]);

        // Sensor 5: Metallic Horn Bell Physical Resonance Array
        metalBodyResonance = DelayC.ar(combinedAcoustics, 0.05, [
            linlin(s5, 0, 127, 0.001, 0.012),
            linlin(s5, 0, 127, 0.0015, 0.015)
        ]);
        combinedAcoustics = combinedAcoustics + (metalBodyResonance * linlin(s5, 0, 127, 0.0, 0.85));

        // Sensor 6: Multi-Instrument Ensemble Phase Chorusing (Simulates a full section)
        phaseChorusing = DelayC.ar(
            combinedAcoustics,
            0.08,
            SinOsc.kr(0.2 + (s6 * 0.1)).range(0.005, 0.035)
        );
        combinedAcoustics = combinedAcoustics + (phaseChorusing * 0.5);

        // Sensor 7: Wide Angle Rotational Stage Panner (Swirls the brass wall around)
        spatialStereo = SinOsc.kr(linlin(s7, 0, 127, 0.1, 1.5)).range(-0.95, 0.95);

        // Global spatial acoustic room reflection
        combinedAcoustics = DelayC.ar(combinedAcoustics, 0.3, LFNoise1.kr(0.08).range(0.01, 0.06)) + (combinedAcoustics * 0.5);

        // High ceiling brickwall stage for a massive, loud, punchy brass delivery
        Out.ar(0, Limiter.ar(Balance2.ar(combinedAcoustics[0], combinedAcoustics[1], spatialStereo, 2.8), 0.98));
    }).add;

    s.sync;

    ~cloudNode = Synth(\rainEngine);

    MIDIdef.freeAll;

    MIDIdef.cc(\atmosphereIn, { |val, num, chan, src|
        var paramSymbol, gatedValue;

        gatedValue = if(val <= 6, { 0 }, { val });
        paramSymbol = ("prox" ++ (num - 20)).asSymbol;
        ~cloudNode.set(paramSymbol, gatedValue);
    }, ccNum: (20..27));

    "The Microtonal Avant-Garde Brass Matrix is roaring. Loud, heavy, and completely independent!".postln;
});
)