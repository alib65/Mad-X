(
s.waitForBoot({
    "Summoning the Independent 4-Channel Generation Matrix...".postln;

    MIDIClient.init;
    MIDIIn.connectAll;

    SynthDef(\rainEngine, {
        arg prox0=0, prox1=0, prox2=0, prox3=0, prox4=0, prox5=0, prox6=0, prox7=0;
        var s0, s1, s2, s3, s4, s5, s6, s7;
        var masterGating, trig0, trig1, trig2, trig3;
        var voice0, voice1, voice2, voice3;
        var combinedAcoustics, qualityFilter, shimmerSpace, chorusDrift, spatialStereo;

        // --- 0. HIGH-ACCURACY EXPONENTIAL INPUT SMOOTHING ---
        s0 = Lag3.kr(Ramp.kr(prox0, 0.05), 0.15);
        s1 = Lag3.kr(Ramp.kr(prox1, 0.05), 0.15);
        s2 = Lag3.kr(Ramp.kr(prox2, 0.05), 0.15);
        s3 = Lag3.kr(Ramp.kr(prox3, 0.05), 0.15);
        s4 = Lag3.kr(Ramp.kr(prox4, 0.05), 0.15);
        s5 = Lag3.kr(Ramp.kr(prox5, 0.05), 0.15);
        s6 = Lag3.kr(Ramp.kr(prox6, 0.05), 0.15);
        s7 = Lag3.kr(Ramp.kr(prox7, 0.05), 0.15);

        // System Master Gate (Wakes up if any of the generation sensors are active)
        masterGating = ((s0 + s1 + s2 + s3) > 1.5).asAudioRateInput;

        // --- 1. FULLY INDEPENDENT SOUND GENERATION (Sensors 0-3) ---

        // SENSOR 0: Deep Earthy Bass Log (Deepest tone)
        trig0 = Dust.ar(linlin(s0, 0, 127, 0, 40) ! 2) * masterGating;
        voice0 = Resonz.ar(Decay.ar(trig0, 0.1) * PinkNoise.ar(0.6 ! 2), 75, 0.06) * 12.0;

        // SENSOR 1: Mid-Range Wooden Block (Wakes up instantly on its own!)
        trig1 = Dust.ar(linlin(s1, 0, 127, 0, 50) ! 2) * masterGating;
        voice1 = Resonz.ar(Decay.ar(trig1, 0.07) * PinkNoise.ar(0.6 ! 2), 220, 0.08) * 10.0;

        // SENSOR 2: Lower Glass Shard Ring
        trig2 = Dust.ar(linlin(s2, 0, 127, 0, 30) ! 2) * masterGating;
        voice2 = Resonz.ar(Decay.ar(trig2, 0.03) * WhiteNoise.ar(0.4 ! 2), 1500, 0.006) * 20.0;

        // SENSOR 3: High Star-Glow Crystal Bell (Wakes up instantly on its own!)
        trig3 = Dust.ar(linlin(s3, 0, 127, 0, 25) ! 2) * masterGating;
        voice3 = Resonz.ar(Decay.ar(trig3, 0.02) * WhiteNoise.ar(0.4 ! 2), 4800, 0.004) * 28.0;

        // Combine all 4 completely independent audio streams
        combinedAcoustics = voice0 + voice1 + voice2 + voice3;

        // --- 2. LUXURY BEAUTIFUL QUALITY MODIFIERS (Sensors 4-7) ---

        // Sensor 4: Liquid Filter Morphing
        qualityFilter = linlin(s4, 0, 127, 400, 16000);
        combinedAcoustics = LPF.ar(combinedAcoustics, qualityFilter.asAudioRateInput);

        // Sensor 5: High-Definition Ice Shimmer Resonator
        shimmerSpace = CombC.ar(combinedAcoustics, 0.1, linlin(s5, 0, 127, 0.001, 0.06), 2.5) * linlin(s5, 0, 127, 0.0, 0.85);
        combinedAcoustics = combinedAcoustics + shimmerSpace;

        // Sensor 6: Multi-Voice Ensemble Chorus Drift
        chorusDrift = DelayC.ar(combinedAcoustics, 0.05, SinOsc.kr(0.1 + (s6 * 0.05)).range(0.005, 0.025)) * 0.5;
        combinedAcoustics = combinedAcoustics + chorusDrift;

        // Sensor 7: Wide Angle Stereo Landscape Panner
        spatialStereo = SinOsc.kr(0.2).range(
            linlin(s7, 0, 127, -0.3, -0.95),
            linlin(s7, 0, 127, 0.2, 0.95)
        );

        // Global luxurious spatial acoustic enhancement
        combinedAcoustics = DelayC.ar(combinedAcoustics, 0.4, LFNoise1.kr(0.1).range(0.01, 0.08)) + (combinedAcoustics * 0.6);

        // Safe brickwall peak safety limiter running a boosted 3.0 volume configuration
        Out.ar(0, Limiter.ar(Balance2.ar(combinedAcoustics[0], combinedAcoustics[1], spatialStereo, 3.2), 0.95));
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

    "All 4 generation channels isolated. Ready to play completely independently!".postln;
});
)