(
s.waitForBoot({
    "Summoning the Morphing Experimental Multi-Material Matrix...".postln;

    MIDIClient.init;
    MIDIIn.connectAll;

    SynthDef(\rainEngine, {
        arg prox0=0, prox1=0, prox2=0, prox3=0, prox4=0, prox5=0, prox6=0, prox7=0;
        var s0, s1, s2, s3, s4, s5, s6, s7;
        var trig0, trig1, trig2, trig3;
        var voice0, voice1, voice2, voice3;
        var combinedAcoustics, ringMod, feedbackSpace, pitchWarp, spatialStereo;

        // --- 0. HIGH-ACCURACY INPUT SMOOTHING ---
        s0 = Lag3.kr(Ramp.kr(prox0, 0.05), 0.15);
        s1 = Lag3.kr(Ramp.kr(prox1, 0.05), 0.15);
        s2 = Lag3.kr(Ramp.kr(prox2, 0.05), 0.15);
        s3 = Lag3.kr(Ramp.kr(prox3, 0.05), 0.15);
        s4 = Lag3.kr(Ramp.kr(prox4, 0.05), 0.15);
        s5 = Lag3.kr(Ramp.kr(prox5, 0.05), 0.15);
        s6 = Lag3.kr(Ramp.kr(prox6, 0.05), 0.15);
        s7 = Lag3.kr(Ramp.kr(prox7, 0.05), 0.15);

        // --- 1. EXPERIMENTAL MATERIAL GENERATION (Sensors 0-3) ---

        // SENSOR 0: Resonant Sub-Surface Earth Log (Uses a Klank resonant harmonic array)
        trig0 = Dust.ar(linlin(s0, 0, 127, 0, 35));
        voice0 = Klank.ar(
            `[[75, 152, 228, 305], nil, [1.0, 0.6, 0.4, 0.2]],
            Decay.ar(trig0, 0.12) * BrownNoise.ar(0.5)
        ) * 4.5 ! 2;

        // SENSOR 1: Liquid Formlet Wood Block (Sensor changes attack/decay shape on the fly)
        trig1 = Dust.ar(linlin(s1, 0, 127, 0, 45));
        voice1 = Formlet.ar(
            Decay.ar(trig1, 0.05) * PinkNoise.ar(0.6),
            220,
            0.005,
            linlin(s1, 0, 127, 0.04, 0.2)
        ) * 12.0 ! 2;

        // SENSOR 2: Multi-Pitch Shard Cloud (Combines two extreme resonant bandwidths)
        trig2 = Dust.ar(linlin(s2, 0, 127, 0, 40));
        voice2 = (
            Resonz.ar(Decay.ar(trig2, 0.02) * WhiteNoise.ar(0.4), 1100, 0.005) * 18.0 +
            Resonz.ar(Decay.ar(trig2, 0.04) * ClipNoise.ar(0.2), 880, 0.009) * 12.0
        ) ! 2;

        // SENSOR 3: Star-Glow Crystal Chime (Unstable ringing frequencies)
        trig3 = Dust.ar(linlin(s3, 0, 127, 0, 30));
        voice3 = Resonz.ar(
            Decay.ar(trig3, 0.01) * Dust2.ar(800),
            linlin(s3, 0, 127, 3600, 6800),
            0.003
        ) * 32.0 ! 2;

        // Combine base engines
        combinedAcoustics = voice0 + voice1 + voice2 + voice3;

        // --- 2. SURREAL MODIFIERS & MODULATORS (Sensors 4-7) ---

        // Sensor 4: Intermodulation Ring Modulator (Cross-modulates signals for metallic tones)
        ringMod = combinedAcoustics * SinOsc.ar(linlin(s4, 0, 127, 30, 1200));
        combinedAcoustics = SelectX.ar(linlin(s4, 0, 127, 0.0, 0.85), [combinedAcoustics, ringMod]);

        // Sensor 5: Spatialized Multi-Tap PingPong Ghost Reverb
        feedbackSpace = DelayN.ar(combinedAcoustics, 0.2, [
            linlin(s5, 0, 127, 0.005, 0.15),
            linlin(s5, 0, 127, 0.01, 0.19)
        ]);
        // Cross feedback route
        combinedAcoustics = combinedAcoustics + (feedbackSpace.reverse * linlin(s5, 0, 127, 0.0, 0.75));

        // Sensor 6: Pitch-Warp Time Stretching Drift
        pitchWarp = DelayC.ar(
            combinedAcoustics,
            0.1,
            LFNoise2.kr(1.5 + (s6 * 0.1)).range(0.002, linlin(s6, 0, 127, 0.005, 0.08))
        );
        combinedAcoustics = combinedAcoustics + (pitchWarp * 0.6);

        // Sensor 7: Expanding Stereo Horizon Panner
        spatialStereo = SinOsc.kr(0.4).range(
            linlin(s7, 0, 127, -0.2, -1.0),
            linlin(s7, 0, 127, 0.2, 1.0)
        );

        // Global Luxuriant Spatial Polish (Ensures deep stereo width without phase cancelation)
        combinedAcoustics = DelayC.ar(combinedAcoustics, 0.3, LFNoise1.kr(0.05).range(0.01, 0.05)) + (combinedAcoustics * 0.5);

        // Massive output safety chain keeping the signal dense, solid, and incredibly loud
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

    "Experimental Multi-Material Grid Engaged. Fully isolated, loud, and alive!".postln;
});
)