(
s.waitForBoot({
    "Summoning the Shimmering Impressionistic Canvas Matrix...".postln;

    MIDIClient.init;
    MIDIIn.connectAll;

    SynthDef(\rainEngine, {
        arg prox0=0, prox1=0, prox2=0, prox3=0, prox4=0, prox5=0, prox6=0, prox7=0;
        var s0, s1, s2, s3, s4, s5, s6, s7;
        var trig0, trig1, trig2, trig3;
        var voice0, voice1, voice2, voice3;
        var combinedAcoustics, waterSurface, paintStrokeCloud, colorDrift, spatialStereo;
        var wholeToneStack, waterGlintFreqs;

        // --- 0. HIGH-ACCURACY INPUT SMOOTHING ---
        s0 = Lag3.kr(Ramp.kr(prox0, 0.05), 0.2);
        s1 = Lag3.kr(Ramp.kr(prox1, 0.05), 0.2);
        s2 = Lag3.kr(Ramp.kr(prox2, 0.05), 0.2);
        s3 = Lag3.kr(Ramp.kr(prox3, 0.05), 0.2);
        s4 = Lag3.kr(Ramp.kr(prox4, 0.05), 0.2);
        s5 = Lag3.kr(Ramp.kr(prox5, 0.05), 0.2);
        s6 = Lag3.kr(Ramp.kr(prox6, 0.05), 0.2);
        s7 = Lag3.kr(Ramp.kr(prox7, 0.05), 0.2);

        // --- 1. IMPRESSIONISTIC SONIC BRUSHSTROKES (Sensors 0-3) ---

        // SENSOR 0: Deep Pastel Resonance (Warm, blurred foundational canvas)
        trig0 = Dust.ar(linlin(s0, 0, 127, 0, 18));
        voice0 = Resonz.ar(
            Decay2.ar(trig0, 0.15, 0.9) * PinkNoise.ar(0.4),
            (57 * [1, 1.122, 1.26, 1.414].choose), // Wandering whole-tone root colors
            0.1
        ) * 15.0 ! 2;

        // SENSOR 1: Parallel Whole-Tone Harps (Blurs textures into a cloud of color)
        trig1 = Dust.ar(linlin(s1, 0, 127, 0, 22));
        wholeToneStack = [220, 246.9, 277.2, 311.1, 349.2, 392.0];
        voice1 = Mix.fill(3, {
            Pluck.ar(
                PinkNoise.ar(0.3),
                trig1,
                0.02,
                wholeToneStack.choose.reciprocal,
                linlin(s1, 0, 127, 0.4, 3.5),
                0.25
            );
        }) * 10.0 ! 2;

        // SENSOR 2: Sunlight on Water (Pointillistic, sparkling high-frequency glints)
        trig2 = Dust2.ar(linlin(s2, 0, 127, 0, 35));
        waterGlintFreqs = [1200, 1348, 1514, 1700, 1908, 2141];
        voice2 = Resonz.ar(
            Decay2.ar(trig2, 0.02, 0.18) * WhiteNoise.ar(0.35),
            Select.kr(TIRand.kr(0, waterGlintFreqs.size - 1, trig2), waterGlintFreqs),
            0.004
        ) * 26.0 ! 2;

        // SENSOR 3: Liquid Air Flute (Wind passing through willow trees)
        trig3 = Dust.ar(linlin(s3, 0, 127, 0, 14));
        voice3 = Resonz.ar(
            Decay2.ar(trig3, 0.08, 0.5) * Crackle.ar(1.85),
            linlin(s3, 0, 127, 2800, 4400) * SinOsc.kr(4, 0, 0.01, 1), // Gentle natural vibrato
            0.008
        ) * 30.0 ! 2;

        // Blend the raw impressionist colors together
        combinedAcoustics = voice0 + voice1 + voice2 + voice3;

        // --- 2. THE VISUAL ATMOSPHERE MODIFIERS (Sensors 4-7) ---

        // Sensor 4: Liquid Reflection Phase-Shifting (Creates rippling water texture)
        waterSurface = combinedAcoustics;
        3.do({ |i|
            waterSurface = AllpassL.ar(
                waterSurface,
                0.05,
                SinOsc.kr(0.05 + (i * 0.02), 0).range(0.002, 0.025),
                linlin(s4, 0, 127, 0.1, 1.8)
            );
        });
        combinedAcoustics = SelectX.ar(linlin(s4, 0, 127, 0.0, 0.8), [combinedAcoustics, waterSurface]);

        // Sensor 5: Pointillistic Paint-Stroke Cloud (Parallel fourth/fifth upper shimmer)
        paintStrokeCloud = PitchShift.ar(combinedAcoustics, 0.15, 1.3348, 0.04, 0.01) * 0.4  // Perfect 4th
                         + PitchShift.ar(combinedAcoustics, 0.2, 1.4983, 0.05, 0.02) * 0.4;  // Perfect 5th
        combinedAcoustics = combinedAcoustics + (paintStrokeCloud * linlin(s5, 0, 127, 0.0, 0.85));

        // Sensor 6: Chiaroscuro Light/Shadow Drift (Modulates warmth vs brightness)
        colorDrift = DelayC.ar(
            combinedAcoustics,
            0.06,
            LFNoise1.kr(0.1).range(0.005, linlin(s6, 0, 127, 0.006, 0.045))
        );
        combinedAcoustics = SelectX.ar(linlin(s6, 0, 127, 0.0, 0.65), [combinedAcoustics, colorDrift]);

        // Sensor 7: Expanding Panoramic Field (Sweeps left and right like wind across a landscape)
        spatialStereo = SinOsc.kr(linlin(s7, 0, 127, 0.03, 0.5)).range(-0.9, 0.9);

        // Global ambient depth to turn direct sounds into out-of-focus background colors
        combinedAcoustics = DelayC.ar(combinedAcoustics, 0.4, LFNoise1.kr(0.02).range(0.03, 0.07)) + (combinedAcoustics * 0.55);

        // Clear brickwall stage ensuring maximum, robust output without clipping the acoustic light
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

    "The Sonic Impressionism Canvas is active. Richly textured, loud, and fully alive!".postln;
});
)