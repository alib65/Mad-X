(
s.waitForBoot({
    "Summoning the Ethereal Dream-State Generation Matrix...".postln;

    MIDIClient.init;
    MIDIIn.connectAll;

    SynthDef(\rainEngine, {
        arg prox0=0, prox1=0, prox2=0, prox3=0, prox4=0, prox5=0, prox6=0, prox7=0;
        var s0, s1, s2, s3, s4, s5, s6, s7;
        var trig0, trig1, trig2, trig3;
        var voice0, voice1, voice2, voice3;
        var combinedAcoustics, dreamCloud, shimmerSpace, tapeWow, spatialStereo;

        // --- 0. HIGH-ACCURACY INPUT SMOOTHING ---
        s0 = Lag3.kr(Ramp.kr(prox0, 0.05), 0.25); // Slightly slower lags for dreamier transitions
        s1 = Lag3.kr(Ramp.kr(prox1, 0.05), 0.25);
        s2 = Lag3.kr(Ramp.kr(prox2, 0.05), 0.25);
        s3 = Lag3.kr(Ramp.kr(prox3, 0.05), 0.25);
        s4 = Lag3.kr(Ramp.kr(prox4, 0.05), 0.25);
        s5 = Lag3.kr(Ramp.kr(prox5, 0.05), 0.25);
        s6 = Lag3.kr(Ramp.kr(prox6, 0.05), 0.25);
        s7 = Lag3.kr(Ramp.kr(prox7, 0.05), 0.25);

        // --- 1. ETHEREAL SOUND GENERATION (Sensors 0-3) ---

        // SENSOR 0: Deep Sub-Oceanic Drone (Low, warm, pulsing hum)
        trig0 = Dust.ar(linlin(s0, 0, 127, 0, 15));
        voice0 = Resonz.ar(
            Decay2.ar(trig0, 0.1, 0.8) * BrownNoise.ar(0.5),
            60 * SinOsc.kr(0.05).range(0.98, 1.02), // subtle wandering tuning
            0.15
        ) * 16.0 ! 2;

        // SENSOR 1: Dream-Harp Plucked String (Uses physical modeling strings)
        trig1 = Dust.ar(linlin(s1, 0, 127, 0, 20));
        voice1 = Pluck.ar(
            PinkNoise.ar(0.4),
            trig1,
            0.02,
            (220 * [1, 1.2, 1.5, 2.0].choose).reciprocal, // Randomizes sweet dream chord tones
            linlin(s1, 0, 127, 0.5, 4.0),
            0.3
        ) * 14.0 ! 2;

        // SENSOR 2: Frosted Glass Shards (Softer, longer decays that smear)
        trig2 = Dust2.ar(linlin(s2, 0, 127, 0, 25));
        voice2 = Resonz.ar(
            Decay2.ar(trig2, 0.05, 0.3) * Crackle.ar(1.9),
            1200,
            0.01
        ) * 22.0 ! 2;

        // SENSOR 3: High Celestial Glow Bells
        trig3 = Dust.ar(linlin(s3, 0, 127, 0, 15));
        voice3 = Resonz.ar(
            Decay2.ar(trig3, 0.01, 0.4) * WhiteNoise.ar(0.3),
            linlin(s3, 0, 127, 3200, 5200),
            0.005
        ) * 32.0 ! 2;

        // Merge the foundational dream streams
        combinedAcoustics = voice0 + voice1 + voice2 + voice3;

        // --- 2. DREAMSCAPE ENHANCERS (Sensors 4-7) ---

        // Sensor 4: Upper-Octave Shimmer Cloud (Generates a halo of overtones)
        dreamCloud = PitchShift.ar(combinedAcoustics, 0.2, 2.0, 0.05, 0.02) * 0.7;
        combinedAcoustics = SelectX.ar(linlin(s4, 0, 127, 0.0, 0.85), [combinedAcoustics, combinedAcoustics + dreamCloud]);

        // Sensor 5: Infinite Diffusion Reverb Matrix (Allpass cloud blur)
        shimmerSpace = combinedAcoustics;
        4.do({
            shimmerSpace = AllpassC.ar(
                shimmerSpace,
                0.1,
                [LFNoise1.kr(0.05).range(0.02, 0.07), LFNoise1.kr(0.05).range(0.03, 0.08)],
                linlin(s5, 0, 127, 0.5, 6.0)
            );
        });
        combinedAcoustics = combinedAcoustics + (shimmerSpace * linlin(s5, 0, 127, 0.0, 0.9));

        // Sensor 6: Nostalgic Tape-Wow Vibrato & Drift
        tapeWow = DelayC.ar(
            combinedAcoustics,
            0.05,
            SinOsc.kr(LFNoise2.kr(0.2).range(0.5, 3.0)).range(0.001, linlin(s6, 0, 127, 0.002, 0.015))
        );
        combinedAcoustics = SelectX.ar(linlin(s6, 0, 127, 0.0, 0.7), [combinedAcoustics, tapeWow]);

        // Sensor 7: Ultra-Wide Hypnotic Circular Panner
        spatialStereo = SinOsc.kr(linlin(s7, 0, 127, 0.05, 0.8)).range(-0.95, 0.95);

        // Global ambient spacious wrap
        combinedAcoustics = DelayC.ar(combinedAcoustics, 0.5, LFNoise1.kr(0.03).range(0.02, 0.09)) + (combinedAcoustics * 0.5);

        // Massive brickwall output to keep the lush pads loud, deep, and beautifully clear
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

    "The Celestial Dreamscape Engine is awake. Deep, isolated, and infinitely vast!".postln;
});
)