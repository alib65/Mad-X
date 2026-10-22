(
s.waitForBoot({
    "Summoning the Persian Santoor Chahargah Matrix...".postln;

    MIDIClient.init;
    MIDIIn.connectAll;

    SynthDef(\rainEngine, {
        arg prox0=0, prox1=0, prox2=0, prox3=0, prox4=0, prox5=0, prox6=0, prox7=0;
        var s0, s1, s2, s3, s4, s5, s6, s7;
        var note0, note1, note2, note3;
        var freq0, freq1, freq2, freq3;
        var trig0, trig1, trig2, trig3;
        var voice0, voice1, voice2, voice3;
        var combinedAcoustics, dynamicResonance, soundboardSustain, sympatheticStrings, spatialStereo;
        var baseD, chahargahScale;

        // --- 0. HIGH-ACCURACY INPUT SMOOTHING ---
        s0 = Lag3.kr(Ramp.kr(prox0, 0.05), 0.12);
        s1 = Lag3.kr(Ramp.kr(prox1, 0.05), 0.12);
        s2 = Lag3.kr(Ramp.kr(prox2, 0.05), 0.12);
        s3 = Lag3.kr(Ramp.kr(prox3, 0.05), 0.12);
        s4 = Lag3.kr(Ramp.kr(prox4, 0.05), 0.18);
        s5 = Lag3.kr(Ramp.kr(prox5, 0.05), 0.18);
        s6 = Lag3.kr(Ramp.kr(prox6, 0.05), 0.18);
        s7 = Lag3.kr(Ramp.kr(prox7, 0.05), 0.18);

        // Tuning Base: Low D (146.83 Hz)
        baseD = 146.83;

        // Precise Just Intonation Ratios for Dastgah-e Chahargah:
        // Root(1/1), E-Koron(24/23), F#(5/4), G(4/3), A(3/2), B-Koron(36/23), C#(15/8), Octave(2/1)
        chahargahScale = [1/1, 24/23, 5/4, 4/3, 3/2, 36/23, 15/8, 2/1, (24/23)*2, (5/4)*2, (4/3)*2, (3/2)*2];

        // --- 1. GESTURAL NOTE SELECTION & MEZRAB TREMOLO GENERATION ---
        // Continuously selects notes from the traditional mode based on hand position
        note0 = linlin(s0, 0, 127, 0, 3).round;  // Low Bass Register strings
        note1 = linlin(s1, 0, 127, 3, 6).round;  // Tenor Register strings
        note2 = linlin(s2, 0, 127, 5, 8).round;  // Mid-High Yellow Strings
        note3 = linlin(s3, 0, 127, 8, 11).round; // High Crystalline White Strings

        // Map selections to Chahargah scale arrays
        freq0 = baseD * Select.kr(note0, chahargahScale);
        freq1 = baseD * Select.kr(note1, chahargahScale);
        freq2 = baseD * Select.kr(note2, chahargahScale);
        freq3 = baseD * Select.kr(note3, chahargahScale);

        // MEZRAB TRIGGER MECHANISM:
        // Combines a trigger spike when moving notes with a steady, furious Santoor tremolo (Riz)
        // that speeds up the closer your hand gets to the sensor!
        trig0 = T2A.ar(Changed.kr(note0)) + Dust.ar(linlin(s0, 10, 127, 0, 24));
        trig1 = T2A.ar(Changed.kr(note1)) + Dust.ar(linlin(s1, 10, 127, 0, 28));
        trig2 = T2A.ar(Changed.kr(note2)) + Dust.ar(linlin(s2, 10, 127, 0, 32));
        trig3 = T2A.ar(Changed.kr(note3)) + Dust.ar(linlin(s3, 10, 127, 0, 35));

        // --- 2. THE SANTOOR PHYSICAL STRING MODEL stage ---
        // Mimics the highly metallic, bright, un-dampened double-string courses of the Santoor

        // Course 0: Deep Kharak Strings (Low resonance)
        voice0 = CombL.ar(
            HPF.ar(Decay2.ar(trig0, 0.001, 0.015) * WhiteNoise.ar(0.4), 200),
            0.1, [freq0.reciprocal, (freq0 * 1.002).reciprocal], 4.0
        ) * 16.0;

        // Course 1: Middle Yellow Strings (Brass texture)
        voice1 = CombL.ar(
            HPF.ar(Decay2.ar(trig1, 0.001, 0.012) * Crackle.ar(1.97), 350),
            0.05, [freq1.reciprocal, (freq1 * 0.9985).reciprocal], 3.5
        ) * 18.0;

        // Course 2: High White Strings (Steel texture)
        voice2 = CombL.ar(
            HPF.ar(Decay2.ar(trig2, 0.0008, 0.01) * WhiteNoise.ar(0.5), 600),
            0.02, [freq2.reciprocal, (freq2 * 1.0015).reciprocal], 2.8
        ) * 24.0;

        // Course 3: Ultra-High Post-Bridge Strings (Glistening wire chime)
        voice3 = CombL.ar(
            HPF.ar(Decay2.ar(trig3, 0.0005, 0.008) * WhiteNoise.ar(0.6), 1200),
            0.01, [freq3.reciprocal, (freq3 * 0.997).reciprocal], 2.0
        ) * 26.0;

        // Mix the overlapping string courses together
        combinedAcoustics = voice0 + voice1 + voice2 + voice3;

        // --- 3. PERSIAN WALNUT WOOD ACOUSTICS & RESONANCE (Sensors 4-7) ---

        // Sensor 4: Box Acoustic Resonance (Simulates the internal hollow walnut box)
        dynamicResonance = Resonz.ar(combinedAcoustics, linlin(s4, 0, 127, 150, 4000), 0.08) * 0.5;
        combinedAcoustics = combinedAcoustics + (dynamicResonance * linlin(s4, 0, 127, 0.0, 1.0));

        // Sensor 5: Sympathetic Un-struck String Ring (Classic shimmering reverb halo)
        soundboardSustain = combinedAcoustics;
        4.do({ |i|
            soundboardSustain = AllpassC.ar(
                soundboardSustain,
                0.05,
                [0.01 + (i * 0.005), 0.012 + (i * 0.006)],
                linlin(s5, 0, 127, 0.5, 5.0)
            );
        });
        combinedAcoustics = combinedAcoustics + (soundboardSustain * linlin(s5, 0, 127, 0.0, 0.85));

        // Sensor 6: Microtonal Pitch Flutter / Micro-Ornamentation (Simulates delicate left-hand finger string pressure)
        sympatheticStrings = DelayC.ar(
            combinedAcoustics,
            0.05,
            SinOsc.kr(LFNoise2.kr(1.5).range(3, 7)).range(0.0005, linlin(s6, 0, 127, 0.0006, 0.004))
        );
        combinedAcoustics = SelectX.ar(linlin(s6, 0, 127, 0.0, 0.6), [combinedAcoustics, sympatheticStrings]);

        // Sensor 7: Geometric Pan Movement (Sweeps the bright string courses across the room)
        spatialStereo = SinOsc.kr(linlin(s7, 0, 127, 0.08, 1.0)).range(-0.9, 0.9);

        // Global master space layout
        combinedAcoustics = DelayC.ar(combinedAcoustics, 0.25, LFNoise1.kr(0.04).range(0.01, 0.03)) + (combinedAcoustics * 0.6);

        // Brickwall limiter optimizing maximum, dense, roaring Santoor outputs safely
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

    "The Persian Santoor Matrix in Dastgah-e Chahargah is live. Move hands to evoke the Mezrab tremolos!".postln;
});
)