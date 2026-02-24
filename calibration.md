---
layout: default
title: Calibrating Your Mics
permalink: /calibration/
nav_order: 1
---


<style>
  .cb { border-radius:14px; padding:1.1rem 1.3rem; margin:0.9rem 0; }
  .cb-blue  { background:linear-gradient(135deg,rgba(37,99,235,0.13),rgba(30,58,138,0.09)); border:1px solid rgba(59,130,246,0.25); }
  .cb-teal  { background:linear-gradient(135deg,rgba(20,184,166,0.13),rgba(13,148,136,0.09)); border:1px solid rgba(20,184,166,0.28); }
  .cb-amber { background:linear-gradient(135deg,rgba(245,158,11,0.13),rgba(180,83,9,0.08)); border:1px solid rgba(245,158,11,0.28); }
  .cb-green { background:linear-gradient(135deg,rgba(34,197,94,0.12),rgba(22,163,74,0.08)); border:1px solid rgba(34,197,94,0.28); }
  .cb-slate { background:rgba(15,23,42,0.04); border:1px solid rgba(148,163,184,0.2); }
  .step { display:flex; gap:0.85rem; align-items:flex-start; margin:0.55rem 0; }
  .step-n { min-width:1.65rem; height:1.65rem; border-radius:50%; background:rgba(59,130,246,0.75); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:800; font-size:0.85rem; flex-shrink:0; margin-top:0.1rem; }
  .eq { background:rgba(15,23,42,0.05); border-left:3px solid rgba(99,102,241,0.6); border-radius:0 8px 8px 0; padding:0.6rem 1rem; margin:0.65rem 0; font-family:ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,'Courier New',monospace; font-size:0.97rem; overflow-x:auto; }
  .tag { display:inline-block; padding:0.15rem 0.55rem; border-radius:999px; font-size:0.8rem; font-weight:700; }
  .tag-m1 { background:rgba(59,130,246,0.15); color:rgba(37,99,235,1); border:1px solid rgba(59,130,246,0.3); }
  .tag-m2 { background:rgba(20,184,166,0.15); color:rgba(13,148,136,1); border:1px solid rgba(20,184,166,0.3); }
  .tag-m3 { background:rgba(245,158,11,0.15); color:rgba(146,64,14,1); border:1px solid rgba(245,158,11,0.3); }
</style>

# Microphone Calibration

RUBAT's calibration factor is a single number — **Pa per ADC unit** — that maps the raw normalised audio samples (range −1 to +1) to physical sound pressure in Pascals. Once entered, the live waveform display switches to **dB SPL re 20 µPa** and the Auto-mode threshold is interpreted in the same absolute scale.

<div class="cb cb-slate" style="margin-top:1rem;">
<strong>How RUBAT uses the factor internally</strong><br><br>

Every audio sample <em>x</em> arriving from the ADC (in the range −1 … +1) is converted as follows:

<div class="eq">
p_Pa  = |x| × C          &nbsp;&nbsp;# instantaneous pressure in Pa<br>
L_SPL = 20 × log₁₀(p_Pa / 20×10⁻⁶)   &nbsp;&nbsp;# dB SPL re 20 µPa
</div>

$$L_{\text{SPL}} = 20 \log_{10}\!\left(\frac{|x| \cdot C}{p_{\text{ref}}}\right), \quad p_{\text{ref}} = 20\,\mu\text{Pa}$$

For the Auto threshold, the inverse is used: given a threshold $L_{\text{thr}}$ in dB SPL, RUBAT computes the equivalent ADC amplitude

$$x_{\text{thr}} = \frac{20\,\mu\text{Pa} \cdot 10^{L_{\text{thr}}/20}}{C}$$

and compares each incoming sample against $x_{\text{thr}}$ directly — no per-sample log is needed in the hot path.
</div>

---

## What is a "Pa per ADC unit"?

A modern audio interface presents samples normalised so that **full-scale digital = 1.0** (and −1.0). The physical voltage that produces that full-scale reading is the interface's **full-scale input voltage**, $V_{\text{FS}}$.

The microphone element produces a voltage proportional to acoustic pressure. Given microphone sensitivity $S_m$ (V/Pa) and total preamp gain $G$ (linear, unitless):

$$C = \frac{V_{\text{FS}}}{S_m \cdot G} \quad \text{[Pa/unit]}$$

Three practical routes to obtain $C$ are described below — choose the one that fits your equipment.

---

## Method 1 — From manufacturer datasheets <span class="tag tag-m1">No extra hardware</span>

You can calculate $C$ entirely from published specifications with no acoustic reference source.

**What you need:**
- Microphone sensitivity (datasheet) — usually given as **mV/Pa** or **dBV/Pa** (re 1 V/Pa)
- Audio interface full-scale input level — usually given as **dBu** or **dBV**
- Preamp gain setting

### Step-by-step

<div class="cb cb-blue">

<div class="step"><div class="step-n">1</div><div>
<strong>Find microphone sensitivity $S_m$.</strong><br>
The datasheet will give a value such as <em>−34 dBV/Pa</em> or <em>20 mV/Pa</em>. Convert to V/Pa:

$$S_m \,[\text{V/Pa}] = 10^{S_{dBV}/20}$$

Example: −34 dBV/Pa → $10^{-34/20} = 0.0200$ V/Pa = 20 mV/Pa
</div></div>

<div class="step"><div class="step-n">2</div><div>
<strong>Convert interface full-scale to Volts peak.</strong><br>
Interface specs often give a maximum input level in dBu (reference 0.775 V<sub>RMS</sub>) or dBV (re 1 V<sub>RMS</sub>):

$$V_{\text{FS, peak}} = \sqrt{2} \cdot 0.775 \cdot 10^{V_{dBu}/20} \quad \text{(if given in dBu)}$$

$$V_{\text{FS, peak}} = \sqrt{2} \cdot 10^{V_{dBV}/20} \quad \text{(if given in dBV)}$$

Example: +18 dBu full scale → $\sqrt{2} \times 0.775 \times 10^{18/20} = 6.16$ V peak.<br><br>

<em>Note:</em> RUBAT's ADC unit corresponds to peak amplitude. If your interface datasheet gives an RMS full-scale figure, multiply by $\sqrt{2}$ to get peak.
</div></div>

<div class="step"><div class="step-n">3</div><div>
<strong>Obtain the preamp gain $G$ (linear).</strong><br>
If the gain knob is set to, e.g., +30 dB:

$$G = 10^{30/20} \approx 31.6$$

If gain is set to 0 dB (unity), then $G = 1$.
</div></div>

<div class="step"><div class="step-n">4</div><div>
<strong>Calculate the calibration factor.</strong>

$$\boxed{C = \frac{V_{\text{FS, peak}}}{S_m \cdot G}}$$

Example: $V_{\text{FS}} = 6.16$ V, $S_m = 0.020$ V/Pa, $G = 31.6$

$$C = \frac{6.16}{0.020 \times 31.6} = \frac{6.16}{0.632} \approx 9.75 \;\text{Pa/unit}$$
</div></div>

</div>

<div class="cb cb-amber">
<strong>⚠ Limitations of the datasheet method</strong><br>
Microphone sensitivities are measured at 1 kHz under controlled conditions. The actual sensitivity of a given unit may differ by a few dB from the nominal value, and gain knob tracking on analogue preamps is rarely exact. Treat this method as a good first estimate — validate it acoustically whenever possible.
</div>

---

## Method 2 — Real-time calibration with a reference sound source <span class="tag tag-m2">Most accurate</span>

A **sound level calibrator** (e.g., a pistonphone or IEC 60942 Class 1 calibrator) emits a pure tone at a precisely known SPL and frequency — typically **94 dB SPL at 1 kHz** or **114 dB SPL at 1 kHz**. This is the standard field method.

<div class="cb cb-teal">

<div class="step"><div class="step-n">1</div><div>
Couple the calibrator to your microphone (most come with adaptors for standard capsule diameters — 1/4", 1/2", 1").
</div></div>

<div class="step"><div class="step-n">2</div><div>
Start the RUBAT stream with <strong>Calibration = 0</strong> (uncalibrated mode). The waveform displays dBFS.
</div></div>

<div class="step"><div class="step-n">3</div><div>
Activate the calibrator. Let the level settle for a few seconds, then note the peak amplitude visible in the waveform. Alternatively, record a short clip (Tap or Continuous) and compute the RMS in MATLAB:

<div class="eq">
[y, fs] = audioread('calibration_clip.wav');<br>
x_rms   = rms(y);         % ADC units (RMS of the 1 kHz tone)
</div>
</div></div>

<div class="step"><div class="step-n">4</div><div>
The reference calibrator produces a known RMS pressure. For a 94 dB SPL tone:

$$p_{\text{ref, RMS}} = 20\,\mu\text{Pa} \times 10^{94/20} = 1.000 \;\text{Pa RMS}$$

For 114 dB SPL → $p_{\text{ref, RMS}} = 10.000$ Pa RMS.
</div></div>

<div class="step"><div class="step-n">5</div><div>
Calculate the factor directly from the ratio:

$$\boxed{C = \frac{p_{\text{ref, RMS}}}{x_{\text{RMS}}}}$$

Example: measured RMS = 0.0412 ADC units during a 94 dB SPL tone:

$$C = \frac{1.000}{0.0412} \approx 24.3 \;\text{Pa/unit}$$
</div></div>

<div class="step"><div class="step-n">6</div><div>
Enter $C$ in the RUBAT <strong>Calibration</strong> field. The waveform should immediately display ~94 dB SPL (or 114 dB SPL, depending on your calibrator). Fine-tune if needed.
</div></div>

</div>

---

## Method 3 — Two-channel comparison with a reference microphone <span class="tag tag-m3">No calibrator needed</span>

If you have one calibrated microphone with a known factor $C_{\text{ref}}$ but want to calibrate a second (test) microphone, you can derive the test factor by recording the same sound source on both channels simultaneously.

<div class="cb cb-green">

<div class="step"><div class="step-n">1</div><div>
Mount both microphones as close together as possible, pointing at the same sound source (a loudspeaker, or any stable broadband source works). Distance between capsules should be much less than the shortest wavelength of interest.
</div></div>

<div class="step"><div class="step-n">2</div><div>
Record a clip with both mics on separate RUBAT input channels (Continuous mode, same gain settings).
</div></div>

<div class="step"><div class="step-n">3</div><div>
Compute the RMS amplitude on each channel over the same time window:

<div class="eq">
[y, fs] = audioread('comparison_clip.wav');<br>
x_ref   = rms(y(:, ch_ref));   % reference mic channel<br>
x_test  = rms(y(:, ch_test));  % test mic channel
</div>
</div></div>

<div class="step"><div class="step-n">4</div><div>
The pressure at both capsules is (approximately) the same, so:

$$p = x_{\text{ref}} \cdot C_{\text{ref}} = x_{\text{test}} \cdot C_{\text{test}}$$

$$\boxed{C_{\text{test}} = C_{\text{ref}} \cdot \frac{x_{\text{ref}}}{x_{\text{test}}}}$$
</div></div>

<div class="step"><div class="step-n">5</div><div>
<strong>Validate the result.</strong> Enter $C_{\text{test}}$ into RUBAT, then record the same source again. The dB SPL reading should match what the reference channel shows with $C_{\text{ref}}$ applied. If they agree within ~1 dB, calibration is satisfactory.
</div></div>

</div>

<div class="cb cb-amber" style="margin-top:0.8rem;">
<strong>⚠ Assumptions and caveats</strong><br>
This method assumes both microphones occupy acoustically identical positions — valid in a free-field if capsule separation ≪ wavelength, but not valid near a reflecting wall or at high frequencies where even a few centimetres of separation introduces a phase difference. For ultrasonic work (&gt;20 kHz), co-locate capsules to within ~1 cm.
</div>

---

## Quick reference — dB SPL ↔ Pa

| dB SPL | Pa (RMS) | Typical source |
|--------|----------|----------------|
| 20 dB | 0.000 2 Pa | Rustling leaves (threshold of hearing) |
| 60 dB | 0.02 Pa | Normal conversation |
| 94 dB | **1 Pa** | Standard calibrator (Class 1) |
| 114 dB | **10 Pa** | Standard calibrator (high-level) |
| 120 dB | 20 Pa | Threshold of discomfort |
| 140 dB | 200 Pa | Jet engine at 30 m |

$$L_{\text{SPL}} = 20 \log_{10}\!\left(\frac{p}{20\,\mu\text{Pa}}\right), \qquad p = 20\,\mu\text{Pa} \times 10^{L/20}$$

---

## Entering the value in RUBAT

The **Calibration** field in the recording panel accepts a value in **Pa per ADC unit**. Enter 0 to disable (dBFS display). The field is available at all times — you can update it while the stream is stopped or running without restarting.

| | Uncalibrated (C = 0) | Calibrated (C > 0) |
|---|---|---|
| Waveform Y axis | dBFS (0 dB = full scale) | dB SPL re 20 µPa |
| Waveform range | −120 dBFS … auto | 0 … 140 dB SPL … auto |
| Auto threshold | Relative amplitude | Absolute dB SPL |
