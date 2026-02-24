---
layout: default
title: Quickstart
permalink: /quickstart/
nav_order: 3
---

<style>
  .qs-figure{
    margin: 1.5rem 0 1.75rem;
    padding: 1rem;
    border: 1px solid rgba(255,255,255,0.08);
    border-radius: 14px;
    background: rgba(255,255,255,0.03);
    box-shadow: 0 10px 24px rgba(0,0,0,0.18);
  }

  .qs-img{
    display:block;
    width:100%;
    height:auto;
    border-radius: 12px;
    border: 1px solid rgba(255,255,255,0.08);
    cursor: zoom-in;
    transition: transform 140ms ease, box-shadow 140ms ease, border-color 140ms ease;
  }

  .qs-img:hover{
    transform: translateY(-2px);
    border-color: rgba(255,255,255,0.18);
    box-shadow: 0 14px 28px rgba(0,0,0,0.28);
  }

  .qs-cap{
    margin-top: 0.75rem;
    font-size: 0.95rem;
    text-align: center;
    color: rgb(0,0,0);
  }

  /* Lightbox Modal */
  .qs-modal {
    display: none;
    position: fixed;
    z-index: 9999;
    padding: 3rem 2rem;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    overflow: auto;
    background: rgba(0,0,0,0.9);
  }

  .qs-modal-content {
    margin: auto;
    display: block;
    max-width: 95%;
    max-height: 90vh;
    border-radius: 12px;
  }

  .qs-close {
    position: absolute;
    top: 20px;
    right: 40px;
    color: #fff;
    font-size: 40px;
    font-weight: bold;
    cursor: pointer;
  }
</style>

# Quickstart

This guide walks through a complete RUBAT Studio session — from launching the application to monitoring and recording ultrasonic data in the field.

The interface is organised into logical panels. Following them from top to bottom ensures a stable, repeatable workflow.

---

## 1. Device Panel — Select & Probe

<figure class="qs-figure">
  <img src="{{ '/assets/quickstart/img/qs_device_panel.png' | relative_url }}" 
       alt="Device Panel"
       class="qs-img"
       loading="lazy"
       onclick="qsOpen(this)">
  <figcaption class="qs-cap">Device Panel</figcaption>
</figure>

**Purpose:** Select input/output hardware and configure sampling parameters.

### Recommended workflow

1. Click **↺ Refresh** to detect connected audio devices.
2. Select your **Input Device** (e.g., multi-channel USB interface).
3. Select your **Output Device** (optional; required for monitoring).
4. Choose:
   - Sample rate (e.g., 192000 Hz for ultrasonic recording)
   - Frame size (buffer)
   - Bit depth (if available)

When a device is selected, RUBAT probes it and logs its capabilities.

✔ Successful probe → channel selection becomes available  
✖ Probe failure → check hardware connection and supported sample rates  

**Important:** Once you press **START**, device controls are locked to prevent mid-stream reconfiguration.

---

## 2. Channel Selection Panel

<figure class="qs-figure">
  <img src="{{ '/assets/quickstart/img/qs_channels.png' | relative_url }}" 
       alt="Channel Selection Panel"
       class="qs-img"
       loading="lazy"
       onclick="qsOpen(this)">
  <figcaption class="qs-cap">Channel Selection Panel</figcaption>
</figure>

**Purpose:** Choose which channels to record and/or monitor.

- Input channels are displayed in a scrollable grid.
- Enable only the channels required for your experiment.
- Output channel selection determines routing for monitoring.

For large devices (e.g., 64 channels), scrolling keeps the interface manageable.

---

## 3. Monitoring Panel — Passthrough & Heterodyne

<figure class="qs-figure">
  <img src="{{ '/assets/quickstart/img/qs_monitoring.png' | relative_url }}" 
       alt="Monitoring & Display Panel"
       class="qs-img"
       loading="lazy"
       onclick="qsOpen(this)">
  <figcaption class="qs-cap">Monitoring & Display Panel</figcaption>
</figure>

**Purpose:** Control real-time listening.

RUBAT supports three monitoring states:

- **Off** — No live output
- **Passthrough** — Direct audible monitoring
- **Heterodyne** — Ultrasonic → audible translation

Heterodyne processing runs in real time and does not affect the recorded WAV file.

Adjust:

- Carrier frequency (e.g., 40–50 kHz)
- Monitoring gain
- Channel routing

---

## 4. Waveform View

<figure class="qs-figure">
  <img src="{{ '/assets/quickstart/img/qs_waveform.png' | relative_url }}" 
       alt="Waveform View"
       class="qs-img"
       loading="lazy"
       onclick="qsOpen(this)">
  <figcaption class="qs-cap">Waveform View</figcaption>
</figure>

**Purpose:** Inspect amplitude over time.

Two display modes are available:

- Relative dB (default)
- Calibrated dB SPL (if calibration factor provided)

Entering a calibration factor (Pa per digital unit) converts values to:

**dB SPL re 20 µPa**

This enables physically meaningful amplitude comparison across sessions and devices.

---

## 5. Spectrogram View

<figure class="qs-figure">
  <img src="{{ '/assets/quickstart/img/qs_spectrogram.png' | relative_url }}" 
       alt="Spectrogram View"
       class="qs-img"
       loading="lazy"
       onclick="qsOpen(this)">
  <figcaption class="qs-cap">Spectrogram View</figcaption>
</figure>

**Purpose:** Visualise frequency content in real time.

Use the spectrogram to:

- Identify bat call structure
- Evaluate signal-to-noise ratio
- Confirm ultrasonic bandwidth capture

Energy is mapped for high field legibility.

---

## 6. Start Streaming

<figure class="qs-figure">
  <img src="{{ '/assets/quickstart/img/qs_run_control.png' | relative_url }}" 
       alt="Run Control Panel"
       class="qs-img"
       loading="lazy"
       onclick="qsOpen(this)">
  <figcaption class="qs-cap">Run Control Panel</figcaption>
</figure>

After configuration:

1. Press **START**
2. Devices open
3. Visuals activate
4. Monitoring begins (if enabled)

The status line confirms sampling rate and streaming state.

---

## 7. Recording Modes

<figure class="qs-figure">
  <img src="{{ '/assets/quickstart/img/qs_rec_modes.png' | relative_url }}" 
       alt="Recording Modes"
       class="qs-img"
       loading="lazy"
       onclick="qsOpen(this)">
  <figcaption class="qs-cap">Recording Modes</figcaption>
</figure>

RUBAT supports three recording modes:

### A. Continuous
Best for long unattended sessions.  
Recording begins immediately and continues until manually stopped.

### B. Tap (Ring Buffer)
Captures what just happened.

Configure:
- Pre-trigger window
- Post-trigger window

Press **Tap Record** during streaming to save pre + post audio.

### C. Auto
Threshold-triggered capture.

Set:
- Detection threshold
- Pre/Post duration
- Required peak count

When threshold conditions are met, RUBAT saves a clip automatically.

Ideal for unattended bat activity monitoring.

---

## 8. Logging Panel

<figure class="qs-figure">
  <img src="{{ '/assets/quickstart/img/qs_logging.png' | relative_url }}" 
       alt="Logging Panel"
       class="qs-img"
       loading="lazy"
       onclick="qsOpen(this)">
  <figcaption class="qs-cap">Logging Panel</figcaption>
</figure>

Every critical event is logged:

- Device probes
- Sample rate selection
- Channel changes
- Monitoring mode changes
- Recording start/stop
- Auto triggers

Logs allow full session reconstruction — essential for reproducible research.

---

## Typical Field Workflow

1. Launch RUBAT  
2. Refresh devices  
3. Select input/output  
4. Verify probe success  
5. Choose channels  
6. Press START  
7. Enable monitoring (if required)  
8. Record (Continuous / Tap / Auto)  
9. Monitor logs  
10. Press STOP before changing devices  

---

## Practical Advice

- Always confirm sample rate compatibility.
- Keep monitoring gain moderate.
- Use calibration for publishable amplitude data.
- Review logs before closing.

You are now ready to deploy RUBAT Studio confidently in laboratory or field environments.

---

<!-- Lightbox Modal -->
<div id="qsModal" class="qs-modal" onclick="qsClose()">
  <span class="qs-close">&times;</span>
  <img class="qs-modal-content" id="qsModalImg">
</div>

<script>
function qsOpen(img){
  var modal = document.getElementById("qsModal");
  var modalImg = document.getElementById("qsModalImg");
  modal.style.display = "block";
  modalImg.src = img.src;
}

function qsClose(){
  document.getElementById("qsModal").style.display = "none";
}
</script>
