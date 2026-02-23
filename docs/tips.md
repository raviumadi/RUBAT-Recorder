---
layout: default
title:  Handy Tips
permalink: /tips/
nav_order: 5
---

<style>
.callout {
  padding: 1rem 1.2rem;
  margin: 1.2rem 0;
  border-radius: 10px;
  border-left: 6px solid;
  background: #f8f9fb;
}
.callout h4 {
  margin-top: 0;
  margin-bottom: 0.5rem;
}
.callout.safety {
  border-color: #e63946;
  background: #fff5f5;
}
.callout.pro {
  border-color: #2a9d8f;
  background: #f1fbf9;
}
.callout.trouble {
  border-color: #f4a261;
  background: #fff8f1;
}
</style>

# Best Practices

Professional audio recording — especially with multiple channels, multiple devices, and complex input/output routing — requires care and understanding.  

Operating a professional multi-channel recording system is more like operating a studio camera: it requires technical awareness, deliberate workflow, and practice.

RUBAT Studio is designed for **real‑time multi‑channel recording** with optional **live monitoring** (passthrough or heterodyne) and **retrospective capture** via a ring buffer. Multi‑device audio routing is powerful, but it can also be unforgiving—these notes help you avoid the most common pitfalls and get clean, reliable recordings.

With practice, the system becomes intuitive — and once your data collection runs smoothly, the learning curve becomes genuinely enjoyable.

---

## Quick start workflow

1. **Select an input device** (top left, ▶ IN).  
2. (Optional) **Select an output device** (▶ OUT). If you choose **(none)**, monitoring is disabled (recommended for first tests).
3. Click **↺ Refresh** to **probe** the selected devices and populate channel lists.
4. In **Channel Selection**, choose the input channels you want to record.
5. Set your **recording mode** (Tap / Continuous / Auto) and your **destination folder**.
6. Press **▶ START**.
7. Use **⏺ RECORD** according to your mode.

**Keyboard shortcuts**
- `s` → START
- `S` → STOP
- `t` → Record button action (Tap / Continuous toggle / Auto arm)
- `x` → Stop Continuous recording (quick safety stop)

---

## Selecting devices & understanding channels

### Input vs output devices
- **Input device**: your microphones / ADC / audio interface inputs.
- **Output device**: headphones / speakers / line‑out used for monitoring.

Many audio interfaces expose **multiple logical outputs** (e.g., 1–8) plus a **headphone bus** that mirrors some mix. In RUBAT, the **Output Channels** selection controls what RUBAT *writes* to the device—your interface may still route that internally depending on its driver/mixer.

### Device not appearing?
If your interface does not show up in a dropdown:
- Confirm the OS sees it (macOS Audio MIDI Setup / Windows Sound settings).
- Install the correct driver/control panel (especially for pro interfaces).
- Disconnect/reconnect the device and try **↺ Refresh**.

---

## Refresh vs probe

RUBAT separates *listing* from *opening*:
- **Device dropdowns at launch** do **not** probe immediately.
- **↺ Refresh** re‑enumerates and then **probes** to confirm sample‑rate/channel availability.

Once you press **START**, device selection controls are locked for the run (this avoids mid‑run PortAudio/CoreAudio instability).

---

## Monitoring modes (optional output)

Monitoring is optional.
- If **Output device = (none)**, **monitoring is off** and monitoring controls are disabled.
- If an output is selected, you can choose:
  - **Off**: no audio is written to output.
  - **Passthrough**: audible monitoring of the selected input.
  - **Heterodyne**: down‑converts ultrasound to audible via a carrier frequency.

<div class="callout safety">
<h4>⚠ Safety</h4>
If microphones and speakers share the same space, acoustic feedback can ramp up instantly.  <br>
• Start with Output mode = Off  <br>
• Prefer headphones  <br>
• Raise Monitor gain slowly <br>
</div>

### Monitoring routing: Mix vs Mon L / Mon R
- **Mix L+R ON**: all selected input channels are **summed** (not averaged) and sent to **both ears**.
- **Mix L+R OFF**: monitoring uses **Mon. Left** and **Mon. Right** to pick the input channels for L/R.

### Output channel selection (L/R gating)
RUBAT treats output channels as:
- **Odd output channels → Left**
- **Even output channels → Right**

If you select only odd channels, monitoring is left‑only; only even channels gives right‑only; selecting both produces stereo.

---

## Sample rate, bit depth, and frame size

### Sample rate
- Choose a rate supported by your input device (common: 48 kHz; ultrasound: 96/192 kHz).
- If input and output sample rates differ, RUBAT will resample for monitoring.

### Bit depth
RUBAT defaults to **32‑bit** where available.
- **Recording is written** with the selected/actual input depth.
- Monitoring runs internally as floating point.

### Frame size (buffer)
Frame size is a key stability/latency knob:
- Smaller frames → lower latency, higher CPU load.
- Larger frames → higher latency, usually fewer dropouts.

If you see dropouts, increase frame size (e.g., 4096 → 8192) before changing anything else.

---

## Visuals and performance

Live waveform + spectrogram cost CPU/GPU.
- If the UI looks “dizzy” or the machine struggles, turn **Visuals** off.
- Keep **UI FPS** reasonable (≤ 20 is often plenty).
- Use **Spec Ymax** to zoom the spectrogram to your band of interest (e.g., set 100000 for 100 kHz) so energy is not compressed at the bottom.

---

## Avoiding dropouts (most important)

The status line under **START** reports:
- **drop**: how often frames arrived late (a practical dropout indicator)
- **dt**: time between frames

<div class="callout pro">
<h4>💡 Pro Tip</h4>
If you see dropouts, increase frame size first (e.g., 4096 → 8192) before changing other settings.
</div>

Dropouts usually mean the audio configuration is not stable.

### Common causes
- **Frame size too small** for the CPU/interface.
- **Heavy resampling** (large mismatch between input and output sample rates).
- **Driver constraints** (some devices enforce fixed buffer sizes).
- **Trying to open/close output streams repeatedly** on the same physical device.

### What to do
1. Set **Output device = (none)** for a clean input‑only test.
2. Increase **Frame size**.
3. Disable **Visuals**.
4. Match input/output **sample rates** where possible.

---

## Recording modes

### Tap (retrospective clip)
You may *tap* into the ring buffer and write out a clip consisting of:
- **Pre** seconds from the ring buffer
- **Post** seconds after the trigger

Use Tap when you want short, precisely captured events.

### Continuous
Continuous writes a file until you stop it.
- **Post** and **Ring** are disabled (by design).

<div class="callout safety">
<h4>⚠ Caution</h4>
Multi-channel high-rate recording generates large files quickly. Monitor disk space.
</div>

<div class="callout pro">
<h4> ✓ Alternative strategy</h4>
Use a longer Post window with larger ring buffer in TAP mode instead of full continuous recording.
</div>

### Auto (threshold‑triggered Tap)
Auto arms a simple event detector on the waveform channel.
- **Thr (dB)**: threshold.
- **Peaks**: number of threshold events required within the last **Pre** seconds.

**Calibration (Pa/u) matters**
- If **Cal (Pa/u) > 0**, the waveform and threshold are interpreted as **dB SPL re 20 µPa**.
- If **Cal (Pa/u) = 0**, the display/threshold are **relative (dBFS)**.

Auto mode is especially useful for field deployments (e.g., bat activity monitoring) where unattended operation is needed.

<div class="callout pro">
<h4>💡 Pro Tip</h4>
If recording short chirps that clearly cross threshold and are separated by at least one buffer frame, Auto mode can significantly reduce manual effort.
</div>
---

## Ensuring WAV file integrity

Before an important session:
- Make a few test recordings in your target configuration.
- Play back and verify channel mapping.
- Confirm the time window (Pre/Post) and sample rate.

If dropouts remain at zero (or very low), WAV files are typically clean.

---

## Good lab habits

- Keep one **project folder** and record all sessions into dated subfolders.
- Add a `readme.txt` in each day’s folder with:
  - device setup
  - gain/phantom settings
  - mic/array geometry
  - notes on the protocol


### File Suffix Feature

Use file suffixes to append metadata (animal ID, experiment name, user, array configuration).

This is especially useful in shared lab environments where multiple projects use the same terminal.

---

<div class="callout trouble">
<h4>🛠 Troubleshooting</h4>
If you see the <strong>drop</strong> counter increasing, monitoring glitches, or PortAudio errors, your system is likely operating near its stability limit. Work through the following steps in order:
<br>
1. <strong>Set Output device = (none)</strong>  <br>
   This isolates input recording and removes monitoring + resampling load. If dropouts disappear, the issue is in the monitoring path.
<br>
2. <strong>Increase Frame size</strong>  <br>
   Larger buffers give the CPU and driver more time to process audio. This is the most effective first fix.
<br>
3. <strong>Disable Visuals</strong>  <br>
   Spectrogram rendering can consume GPU/CPU resources, especially at high sample rates.
<br>
4. <strong>Match input/output sample rates</strong>  <br>
   Resampling adds processing overhead. Keeping both devices at the same sample rate reduces load.
<br>
5. <strong>Stop → Refresh → Restart</strong>  <br>
   If PortAudio or driver errors appear, fully stop the stream, refresh devices, and start again. Avoid repeatedly opening/closing writers mid‑run.<br>
</div>

---

## Final Checklist Before Recording

- Devices selected correctly?
- Channels mapped correctly?
- Sample rate supported?
- Monitoring safe?
- Drop counter stable?

If yes — you are ready to record with confidence.