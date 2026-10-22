(
s.waitForBoot({
    "Summoning the 21-EDO Advanced Physical String Matrix...".postln;

    MIDIClient.init;
    MIDIIn.connectAll;

    SynthDef(\rainEngine, {
        arg prox0=0, prox1=0, prox2=0, prox3=0, prox4=0, prox5=0, prox6=0, prox7=0;
        var s0, s1, s2, s3, s4, s5, s6, s7;
        var note0, note1, note2, note3;
        var freq0, freq1, freq2, freq3;
        var trig0, trig1, trig2, trig3;
        var voice0, voice1, voice2, voice3;
        var combinedAcoustics, dynamicPhaser, spaceDiffusion, feedbackHiss, spatialStereo;
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

        // Middle C (261.63 Hz) serves as the 21-EDO mathematical origin
        baseC = 261.63;

        // --- 1. DYNAMIC 21-EDO STEP QUANTIZATION (Sensors 0-3) ---
        // Sets up 21 discrete notes per octave limit maps
        note0 = linlin(s0, 0, 127, -21, 0).round;   // Bass String Array
        note1 = linlin(s1, 0, 127, 0, 21).round;    // Plucked Tenor Key Array
        note2 = linlin(s2, 0, 127, 10, 31).round;   // Bowed Mid-Register Array
        note3 = linlin(s3, 0, 127, 21, 47).round;   // Glistening Tine String Array

        // 21-EDO Mathematical Tuning Formula: Freq = Base * 2^(Step / 21)
        freq0 = baseC * (2 ** (note0 / 21));
        freq1 = baseC * (2 ** (note1 / 21));
        freq2 = baseC * (2 ** (note2 / 21));
        freq3 = baseC * (2 ** (note3 / 21));

        // Note Change Triggers for hand gestures
        trig0 = T2A.ar(Changed.kr(note0));
        trig1 = T2A.ar(Changed.kr(note1));
        trig2 = T2A.ar(Changed.kr(note2));
        trig3 = T2A.ar(Changed.kr(note3));

        // --- 2. MULTI-TECHNIQUE STRING SYNTHESIS ENGINE ---

        // TECHNIQUE 0: Sympathetic Resonance (Deep, ringing string wash)
        voice0 = Ringz.ar(
            Decay2.ar(trig0, 0.005, 0.04) * BrownNoise.ar(0.3),
            freq0,
            4.0 // Long, beautiful ring decay time
        ) * 12.0 ! 2;

        // TECHNIQUE 1: Plucked Karplus-Strong Modeling (Sharp attack, organic piano-wood)
        voice1 = Pluck.ar(
            PinkNoise.ar(0.6),
            trig1,
            0.05,
            freq1.reciprocal,
            3.5, // Decays over several seconds
            0.35 // Dampening parameter mimicking a felt hammer
        ) * 16.0 ! 2;

        // TECHNIQUE 2: Ethereal Bowed Waveguide (Continuous friction modeling triggered on note shift)
        voice2 = CombC.ar(
            EnvGen.ar(Env.perc(0.1, 1.2), trig2) * LFNoise2.ar(freq2) * WhiteNoise.ar(0.15),
            0.03,
            [freq2.reciprocal, (freq2 * 1.002).reciprocal],
            2.5
        ) * 22.0;

        // TECHNIQUE 3: Struck Harpsichord Tines (Split-Phase high metallic transients)
        voice3 = CombL.ar(
            HPF.ar(Decay2.ar(trig3, 0.001, 0.01) * Crackle.ar(1.98), 800),
            0.01,
            freq3.reciprocal,
            1.2
        ) * 28.0 ! 2;

        // Merge all 4 unique string textures
        combinedAcoustics = voice0 + voice1 + voice2 + voice3;

        // --- 3. CREATIVE POST-SPACE ARCHITECTURE (Sensors 4-7) ---

        // Sensor 4: Dynamic Phase Ripple (Sweeps microtonal string overtones)
        dynamicPhaser = combinedAcoustics;
        3.do({ |i|
            dynamicPhaser = AllpassL.ar(
                dynamicPhaser,
                0.04,
                SinOsc.kr(0.08 + (i * 0.03)).range(0.001, 0.02),
                linlin(s4, 0, 127, 0.1, 2.5)
            );
        });
        combinedAcoustics = SelectX.ar(linlin(s4, 0, 127, 0.0, 0.75), [combinedAcoustics, dynamicPhaser]);

        // Sensor 5: Sympathetic Soundboard Diffusion Cloud (Infinite body resonance)
        spaceDiffusion = combinedAcoustics;
        4.do({
            spaceDiffusion = AllpassC.ar(
                spaceDiffusion,
                0.06,
                [LFNoise1.kr(0.03).range(0.01, 0.04), LFNoise1.kr(0.03).range(0.012, 0.042)],
                linlin(s5, 0, 127, 0.3, 6.0)
            );
        });
        combinedAcoustics = combinedAcoustics + (spaceDiffusion * linlin(s5, 0, 127, 0.0, 0.85));

        // Sensor 6: Tape Saturator / Bow Friction Growl
        feedbackHiss = (combinedAcoustics * linlin(s6, 0, 127, 1.0, 4.0)).tanh;
        combinedAcoustics = SelectX.ar(linlin(s6, 0, 127, 0.0, 0.55), [combinedAcoustics, feedbackHiss]);

        // Sensor 7: Geometric Acoustic Stereo Field Panner
        spatialStereo = SinOsc.kr(linlin(s7, 0, 127, 0.05, 1.4)).range(-0.95, 0.95);

        // Global ambient room binding
        combinedAcoustics = DelayC.ar(combinedAcoustics, 0.3, LFNoise1.kr(0.05).range(0.01, 0.05)) + (combinedAcoustics * 0.55);

        // Brickwall production stage for massive, stable volume delivery without clipping
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

    "The 21-EDO Multi-Technique String Matrix is live. Move hands on 0-3 to excite the spaces!".postln;
});
)