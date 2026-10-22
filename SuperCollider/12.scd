(
s.waitForBoot({
    "Summoning the Resonating 19-EDO Microtonal Piano Matrix...".postln;

    MIDIClient.init;
    MIDIIn.connectAll;

    SynthDef(\rainEngine, {
        arg prox0=0, prox1=0, prox2=0, prox3=0, prox4=0, prox5=0, prox6=0, prox7=0;
        var s0, s1, s2, s3, s4, s5, s6, s7;
        var note0, note1, note2, note3;
        var freq0, freq1, freq2, freq3;
        var trig0, trig1, trig2, trig3;
        var voice0, voice1, voice2, voice3;
        var combinedAcoustics, hornGrowl, metalBodyResonance, phaseChorusing, spatialStereo;
        var baseC;

        // --- 0. HIGH-ACCURACY INPUT SMOOTHING ---
        s0 = Lag3.kr(Ramp.kr(prox0, 0.05), 0.1);
        s1 = Lag3.kr(Ramp.kr(prox1, 0.05), 0.1);
        s2 = Lag3.kr(Ramp.kr(prox2, 0.05), 0.1);
        s3 = Lag3.kr(Ramp.kr(prox3, 0.05), 0.1);
        s4 = Lag3.kr(Ramp.kr(prox4, 0.05), 0.18);
        s5 = Lag3.kr(Ramp.kr(prox5, 0.05), 0.18);
        s6 = Lag3.kr(Ramp.kr(prox6, 0.05), 0.18);
        s7 = Lag3.kr(Ramp.kr(prox7, 0.05), 0.18);

        // Middle C (261.63 Hz) serves as our 19-EDO anchor point
        baseC = 261.63;

        // --- 1. DYNAMIC 19-EDO STEP QUANTIZATION (Sensors 0-3) ---
        note0 = linlin(s0, 0, 127, -19, 0).round;   // Deep Bass Piano Register
        note1 = linlin(s1, 0, 127, 0, 19).round;    // Tenor Piano Register
        note2 = linlin(s2, 0, 127, 10, 29).round;   // Mid-High Piano Register
        note3 = linlin(s3, 0, 127, 19, 45).round;   // Celestial Bell / High Felt Tines Register

        // Mathematical conversion formula for 19-EDO
        freq0 = baseC * (2 ** (note0 / 19));
        freq1 = baseC * (2 ** (note1 / 19));
        freq2 = baseC * (2 ** (note2 / 19));
        freq3 = baseC * (2 ** (note3 / 19));

        // --- 2. RELIABLE DYNAMIC TRANSITIONAL TRIGGERS ---
        // Changed.kr outputs a 1-control-period spike when the note value shifts.
        // T2A.ar converts this control spike into a perfect audio-rate strike pulse.
        trig0 = T2A.ar(Changed.kr(note0));
        trig1 = T2A.ar(Changed.kr(note1));
        trig2 = T2A.ar(Changed.kr(note2));
        trig3 = T2A.ar(Changed.kr(note3));

        // --- 3. PHYSICAL MODELING PIANO STRIKE ENGINE ---

        // SENSOR 0: Deep Bass Piano Strings
        voice0 = CombL.ar(
            Decay2.ar(trig0, 0.002, 0.03) * WhiteNoise.ar(0.5),
            0.1, freq0.reciprocal, 5.0
        ) * 22.0 ! 2;

        // SENSOR 1: Main Mid-Register Felt Piano Keys
        voice1 = CombL.ar(
            Decay2.ar(trig1, 0.001, 0.02) * PinkNoise.ar(0.6),
            0.05, [freq1.reciprocal, (freq1 * 1.0015).reciprocal], 3.5
        ) * 18.0;

        // SENSOR 2: High Bell Piano Tines
        voice2 = CombL.ar(
            Decay2.ar(trig2, 0.001, 0.015) * WhiteNoise.ar(0.5),
            0.02, [freq2.reciprocal, (freq2 * 0.9985).reciprocal], 2.2
        ) * 28.0;

        // SENSOR 3: Upper-Register Toy Piano / Felt Plucks
        voice3 = CombL.ar(
            Decay2.ar(trig3, 0.0005, 0.01) * Crackle.ar(1.96),
            0.01, freq3.reciprocal, 1.5
        ) * 32.0 ! 2;

        // Combine the independent piano strings
        combinedAcoustics = voice0 + voice1 + voice2 + voice3;

        // --- 4. EXPERIMENTAL MODIFIERS & HORN RESIDUE (Sensors 4-7) ---

        // Sensor 4: Harmonic Growl & Saturated Drive
        hornGrowl = combinedAcoustics * SinOsc.ar(LFNoise2.kr(8).range(25, 90));
        hornGrowl = (hornGrowl * linlin(s4, 0, 127, 1.0, 3.0)).distort;
        combinedAcoustics = SelectX.ar(linlin(s4, 0, 127, 0.0, 0.65), [combinedAcoustics, hornGrowl]);

        // Sensor 5: Sympathetic Soundboard Reflection Matrix
        metalBodyResonance = DelayC.ar(combinedAcoustics, 0.05, [
            linlin(s5, 0, 127, 0.001, 0.012),
            linlin(s5, 0, 127, 0.0015, 0.015)
        ]);
        combinedAcoustics = combinedAcoustics + (metalBodyResonance * linlin(s5, 0, 127, 0.0, 0.85));

        // Sensor 6: Multi-Instrument Ensemble Phase Chorusing
        phaseChorusing = DelayC.ar(
            combinedAcoustics,
            0.08,
            SinOsc.kr(0.2 + (s6 * 0.1)).range(0.005, 0.035)
        );
        combinedAcoustics = combinedAcoustics + (phaseChorusing * 0.5);

        // Sensor 7: Wide Angle Rotational Panner
        spatialStereo = SinOsc.kr(linlin(s7, 0, 127, 0.1, 1.5)).range(-0.95, 0.95);

        // Global spatial acoustic room reflection
        combinedAcoustics = DelayC.ar(combinedAcoustics, 0.3, LFNoise1.kr(0.08).range(0.01, 0.06)) + (combinedAcoustics * 0.5);

        // Stable peak safety limiter driving maximum volume output
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

    "The 19-EDO Microtonal Piano Matrix is live. Move your hands across sensors 0-3 to strike the notes!".postln;
});
)