---
layout: default
title: RUBAT Studio
permalink: /
nav_order: 1
---

<style>
  /* Click-to-zoom affordance */
  .rb-zoom{
    cursor: zoom-in;
    transition: transform 140ms ease, box-shadow 140ms ease, border-color 140ms ease;
  }
  .rb-zoom:hover{
    transform: translateY(-2px);
    box-shadow: 0 14px 28px rgba(0,0,0,0.28);
    border-color: rgba(255,255,255,0.18) !important;
  }

  /* Lightbox Modal */
  .rb-modal {
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

  .rb-modal-content {
    margin: auto;
    display: block;
    max-width: 95%;
    max-height: 90vh;
    border-radius: 12px;
  }

  .rb-close {
    position: absolute;
    top: 18px;
    right: 34px;
    color: #fff;
    font-size: 40px;
    font-weight: 700;
    cursor: pointer;
    line-height: 1;
    opacity: 0.9;
  }
  .rb-close:hover{ opacity: 1; }

  /* Optional: caption */
  .rb-modal-caption{
    margin: 0.9rem auto 0;
    max-width: 95%;
    color: rgba(226,232,240,0.9);
    text-align: center;
    font-size: 0.95rem;
  }
</style>

# Realtime Unified BioAcoustic Tool

<div style="margin:1.25rem 0 1.5rem; padding:1.5rem; border-radius:16px; background:linear-gradient(135deg, rgb(78, 100, 143), rgb(27, 68, 34)); color:rgba(229,231,235,1); box-shadow:0 12px 28px rgba(0,0,0,0.28);">

  <!-- Full-width image -->
  <div style="border-radius:14px; overflow:hidden; border:1px solid rgba(90,149,231,0.18); background:rgba(255,255,255,0.03);">
    <img src="{{ '/assets/home/img/rubat_firstview.png' | relative_url }}" 
         alt="RUBAT Studio UI" 
         class="rb-zoom"
         onclick="rbOpen(this)"
         style="width:100%; height:auto; display:block;" />
  </div>

  <!-- Description below image -->
  <div style="margin-top:1.5rem;">
    <div style="font-size:0.95rem; letter-spacing:0.02em; color:rgba(147,197,253,1); font-weight:700;">Sounds and Senses Lab</div>
    <div style="font-size:1.4rem; font-weight:800; line-height:1.25; margin-top:0.45rem;">
      Live audio-visual monitoring & high-fidelity multichannel recording
    </div>
    <div style="margin-top:0.75rem; color:rgba(203,213,225,1); line-height:1.6; font-size:1.05rem;">
      RUBAT Studio is a MATLAB-based recorder built for field bioacoustics — designed to capture high-sample-rate audio while giving you real-time heterodyne monitoring, responsive visualisation, and robust recording workflows.
    </div>
    <div style="margin-top:1rem; display:flex; flex-wrap:wrap; gap:0.6rem;">
      <span style="padding:0.3rem 0.7rem; border-radius:999px; background:rgba(59,130,246,0.18); border:1px solid rgba(59,130,246,0.35);">Flexible workflows</span>
      <span style="padding:0.3rem 0.7rem; border-radius:999px; background:rgba(16,185,129,0.16); border:1px solid rgba(16,185,129,0.30);">Realtime monitoring</span>
      <span style="padding:0.3rem 0.7rem; border-radius:999px; background:rgba(249,115,22,0.14); border:1px solid rgba(249,115,22,0.30);">Tap / Continuous / Auto</span>
      <span style="padding:0.3rem 0.7rem; border-radius:999px; background:rgba(168,85,247,0.14); border:1px solid rgba(168,85,247,0.30);">Multichannel audio streams</span>
      <span style="padding:0.3rem 0.7rem; border-radius:999px; background:rgba(247, 85, 134, 0.14); border:1px solid rgba(168,85,247,0.30);">Record ANY sound</span>
    </div>
  </div>

</div>

---

## What is it good for?

RUBAT Studio was designed to address the practical challenges of ultrasonic field recording, but its architecture makes it equally suitable for general multichannel audio projects.

For bioacoustics and fieldwork, it enables you to:
- **Monitor audio live** while recording full-bandwidth data via heterodyne or passthrough modes.
- **Handle many channels** cleanly using selectable input/output channel masks.
- **Capture what just happened** with a ring buffer and tap recording.
- **Trigger recordings automatically** using threshold-based Auto mode.
- **Reduce failures in the field** through explicit device probing and predictable run controls.

Beyond ultrasonic work, RUBAT can also function as a robust multichannel recorder for music, voice, and studio-style sessions:
- Record multiple microphones or instruments simultaneously.
- Track vocals against a backing track on separate channels.
- Capture rehearsals, demos, or live sessions with ordered and tagged WAV files.

In short, RUBAT combines research-grade reliability with studio flexibility — whether you’re documenting insect/bat/bird calls, or recording a multitrack performance indoors.

---

<div style="margin:1rem 0 1.25rem; padding:1rem 1.1rem; border-radius:14px; border:1px solid rgba(10, 45, 16, 0.8); background:rgba(13, 45, 6, 0.95);">
  <div style="font-weight:900; color:rgba(147,197,253,1);">How to pronounce “RUBAT”</div>

  <div style="margin-top:0.35rem; color:rgb(255, 255, 255); line-height:1.55;">
    Say it like <b>“Rue-BAT”</b>.
    <span style="opacity:0.95;">“Rue” rhymes with <b>“blue”</b> (like “roo”), then “bat”.</span>
  </div>

  <div style="margin-top:0.45rem; font-size:0.95rem; color:rgb(197, 94, 31);">
    <b>Phonetic:</b>
    <span style="font-family:ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace;">ROO-bat</span>
    &nbsp;·&nbsp;
    <b>IPA:</b>
    <span style="font-family:ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace;">/ˈruː.bæt/</span>
  </div>

  <div style="margin-top:0.85rem;">
    <audio controls style="width:100%; margin-top:0.25rem;">
      <source src="{{ '/assets/home/audio/rubat_pronunciation.wav' | relative_url }}" type="audio/wav">
      Your browser does not support the audio element.
    </audio>
    <div style="margin-top:0.6rem; font-size:0.85rem; color:rgba(51,65,85,0.95);"></div>
  </div>
</div>

---

## Key capabilities

<div style="display:flex; flex-direction:column; gap:0.9rem; margin:1rem 0 0.25rem;">

  <!-- 1 -->
<div style="padding:1rem; border-radius:16px; border:1px solid rgba(226,232,240,0.18); background:linear-gradient(135deg, rgba(37,99,235,0.26), rgba(30,58,138,0.18)); color:rgba(15,23,42,1);">
  <div style="overflow:hidden;">
    <video muted loop playsinline
    onmouseover="this.play()"
       onmouseout="this.pause(); this.currentTime=0;"
       style="float:right; width:45%; max-width:520px; height:auto; border-radius:12px; border:1px solid rgba(148,163,184,0.14); margin-left:1rem; margin-bottom:0.5rem;">
  <source src="{{ '/assets/home/video/heterodyne.mp4' | relative_url }}" type="video/mp4">
</video>
    <div>
      <div style="font-weight:900; font-size:1.05rem;">Continuous monitoring</div>
      <div style="margin-top:0.45rem; line-height:1.6;">
        Bat calls are shifted into the audible range by multiplying the signal against a sine carrier whose phase accumulates continuously across frames — no clicks or discontinuities at frame boundaries. Dial the carrier frequency across the full spectrum up to the Nyquist limit. Switch freely between <b>Off</b>, <b>Passthrough</b>, and <b>Heterodyne</b> while the stream is live, without restarting.
      </div>
    </div>
  </div>
</div>

  <!-- 2 -->
  <div style="padding:1rem; border-radius:16px; border:1px solid rgba(226,232,240,0.18); background:linear-gradient(135deg, rgba(59,130,246,0.24), rgba(29,78,216,0.16)); color:rgba(15,23,42,1);">
    <div style="overflow:hidden;">
      <video muted loop playsinline
    onmouseover="this.play()"
       onmouseout="this.pause(); this.currentTime=0;"
       style="float:right; width:45%; max-width:520px; height:auto; border-radius:12px; border:1px solid rgba(148,163,184,0.14); margin-left:1rem; margin-bottom:0.5rem;">
  <source src="{{ '/assets/home/video/feature_channels.mp4' | relative_url }}" type="video/mp4">
</video>
      <div>
        <div style="font-weight:900; font-size:1.05rem; color:rgba(15,23,42,1);">True N-channel in → out routing</div>
        <div style="color:rgba(30,41,59,0.95); margin-top:0.45rem; line-height:1.6;">
          Each selected input channel is routed one-to-one to the matching physical output channel. A per-channel output mask gates which physical outputs carry audio; unselected outputs stay silent. <b>Mix mode</b> sums odd-indexed inputs to the left ear and even-indexed to the right, giving intuitive stereo headphone monitoring of a microphone array.
        </div>
      </div>
    </div>
  </div>

  <!-- 3 -->
  <div style="padding:1rem; border-radius:16px; border:1px solid rgba(226,232,240,0.18); background:linear-gradient(135deg, rgba(56,189,248,0.22), rgba(14,116,144,0.16)); color:rgba(15,23,42,1);">
    <div style="overflow:hidden;">
      <video muted loop playsinline
    onmouseover="this.play()"
       onmouseout="this.pause(); this.currentTime=0;"
       style="float:right; width:45%; max-width:520px; height:auto; border-radius:12px; border:1px solid rgba(148,163,184,0.14); margin-left:1rem; margin-bottom:0.5rem;">
  <source src="{{ '/assets/home/video/feature_tap.mp4' | relative_url }}" type="video/mp4">
</video>
      <div>
        <div style="font-weight:900; font-size:1.05rem; color:rgba(15,23,42,1);">Ring buffer tap — capture what just happened</div>
        <div style="color:rgba(30,41,59,0.95); margin-top:0.45rem; line-height:1.6;">
          A continuously-written ring buffer keeps the last N seconds of audio in memory at all times. Pressing <b>TAP</b> trims out a clip that starts <em>before</em> you pressed the button — set the <b>pre-trigger</b> window independently from the <b>post-trigger</b> window. You are never racing against a passing interesting event; you already have it.
        </div>
      </div>
    </div>
  </div>

  <!-- 4 -->
  <div style="padding:1rem; border-radius:16px; border:1px solid rgba(226,232,240,0.18); background:linear-gradient(135deg, rgba(34,211,238,0.20), rgba(13,148,136,0.16)); color:rgba(15,23,42,1);">
    <div style="overflow:hidden;">
      <video muted loop playsinline
    onmouseover="this.play()"
       onmouseout="this.pause(); this.currentTime=0;"
       style="float:right; width:45%; max-width:520px; height:auto; border-radius:12px; border:1px solid rgba(148,163,184,0.14); margin-left:1rem; margin-bottom:0.5rem;">
  <source src="{{ '/assets/home/video/feature_auto.mp4' | relative_url }}" type="video/mp4">
</video>
      <div>
        <div style="font-weight:900; font-size:1.05rem; color:rgba(15,23,42,1);">Auto mode — unattended threshold recording</div>
        <div style="color:rgba(30,41,59,0.95); margin-top:0.45rem; line-height:1.6;">
          Arm <b>Auto</b> and walk away. Each time signal energy in the pre-trigger window crosses the threshold, RUBAT fires a tap automatically. No classifier required — a lightweight energy check is sufficient and adds negligible CPU overhead to the audio loop.
        </div>
      </div>
    </div>
  </div>

  <!-- 5 -->
  <div style="padding:1rem; border-radius:16px; border:1px solid rgba(226,232,240,0.18); background:linear-gradient(135deg, rgba(45,212,191,0.20), rgba(15,118,110,0.16)); color:rgba(15,23,42,1);">
    <div style="overflow:hidden;">
      <video muted loop playsinline
    onmouseover="this.play()"
       onmouseout="this.pause(); this.currentTime=0;"
       style="float:right; width:45%; max-width:520px; height:auto; border-radius:12px; border:1px solid rgba(148,163,184,0.14); margin-left:1rem; margin-bottom:0.5rem;">
  <source src="{{ '/assets/home/video/feature_spl.mp4' | relative_url }}" type="video/mp4">
</video>
      <div>
        <div style="font-weight:900; font-size:1.05rem; color:rgba(15,23,42,1);">Calibrated dB SPL waveform display</div>
        <div style="color:rgba(30,41,59,0.95); margin-top:0.45rem; line-height:1.6;">
          Supply a <em>Pa-per-unit</em> sensitivity calibration factor and the live waveform panel switches to <b>dB SPL re 20 µPa</b> — quantitative and comparable across sessions and microphone models. Without calibration the display falls back to a relative dBFS view, so the panel is always informative regardless of setup.
        </div>
      </div>
    </div>
  </div>

  <!-- 6 -->
  <div style="padding:1rem; border-radius:16px; border:1px solid rgba(226,232,240,0.18); background:linear-gradient(135deg, rgba(16,185,129,0.20), rgba(5,150,105,0.16)); color:rgba(15,23,42,1);">
    <div style="overflow:hidden;">
      <video muted loop playsinline
    onmouseover="this.play()"
       onmouseout="this.pause(); this.currentTime=0;"
       style="float:right; width:45%; max-width:520px; height:auto; border-radius:12px; border:1px solid rgba(148,163,184,0.14); margin-left:1rem; margin-bottom:0.5rem;">
  <source src="{{ '/assets/home/video/feature_spec.mp4' | relative_url }}" type="video/mp4">
</video>
      <div>
        <div style="font-weight:900; font-size:1.05rem; color:rgba(15,23,42,1);">Dual greyscale spectrograms</div>
        <div style="color:rgba(30,41,59,0.95); margin-top:0.45rem; line-height:1.6;">
          Two independent spectrogram panes, each assignable to any selected input channel. Energy is mapped black&nbsp;→&nbsp;white on a dark background — maximum contrast for reading call structure in bright daylight or in the twilight. Set view via Y scaling in Hz at any time.
        </div>
      </div>
    </div>
  </div>

  <!-- 7 -->
  <div style="padding:1rem; border-radius:16px; border:1px solid rgba(226,232,240,0.18); background:linear-gradient(135deg, rgba(34,197,94,0.20), rgba(22,163,74,0.16)); color:rgba(15,23,42,1);">
    <div style="overflow:hidden;">
      <video muted loop playsinline
    onmouseover="this.play()"
       onmouseout="this.pause(); this.currentTime=0;"
       style="float:right; width:45%; max-width:520px; height:auto; border-radius:12px; border:1px solid rgba(148,163,184,0.14); margin-left:1rem; margin-bottom:0.5rem;">
  <source src="{{ '/assets/home/video/feature_logging.mp4' | relative_url }}" type="video/mp4">
</video>
      <div>
        <div style="font-weight:900; font-size:1.05rem; color:rgba(15,23,42,1);">Robust device handling &amp; logging</div>
        <div style="color:rgba(30,41,59,0.95); margin-top:0.45rem; line-height:1.6;">
          Input-Output channels count is querried and validated. Device and channel controls lock during streaming to prevent accidental re-probes. All events are written to a live log.
        </div>
      </div>
    </div>
  </div>

  <!-- 8 -->
  <div style="padding:1rem; border-radius:16px; border:1px solid rgba(226,232,240,0.18); background:linear-gradient(135deg, rgba(74,222,128,0.18), rgba(21,128,61,0.16)); color:rgba(15,23,42,1);">
    <div style="display:flex; gap:1rem; align-items:flex-start; flex-wrap:wrap;">
      <div style="flex:1; min-width:260px;">
        <div style="font-weight:900; font-size:1.05rem; color:rgba(15,23,42,1);">Three recording modes + keyboard shortcuts</div>
        <div style="color:rgba(30,41,59,0.95); margin-top:0.45rem; line-height:1.6;">
          <b>✓ Tap</b> — single pre+post clip from the ring buffer, triggered manually.<br>
          <b>✓ Continuous</b> — streams directly to a sequentially-numbered WAV file until you stop.<br>
          <b>✓ Auto</b> — arms Tap so the detector fires it for you unattended.<br>
        </div>
      </div>
    </div>
  </div>

</div>

<!-- ---

## Example recording

<div style="margin:1.25rem 0; padding:1.25rem; border-radius:14px; background:linear-gradient(135deg,#0b1220,#111827); color:#e5e7eb; box-shadow:0 10px 24px rgba(0,0,0,0.25);">
  <div style="display:flex; align-items:flex-start; justify-content:space-between; gap:1rem; flex-wrap:wrap;">
    <div style="min-width:240px;">
      <div style="font-size:0.95rem; color:#93c5fd; font-weight:700;">Field example</div>
      <div style="font-size:1.15rem; font-weight:800; margin-top:0.25rem;">Myotis daubentonii — heterodyne preview</div>
      <div style="margin-top:0.45rem; color:#cbd5e1; line-height:1.55;">Recorded at 192 kHz. Monitoring enabled. Full-bandwidth WAV archived.</div>
    </div>
    <div style="min-width:280px; flex:1;">
      <audio controls style="width:100%; margin-top:0.25rem;">
        <source src="{{ '/assets/audio/example_bat_call.wav' | relative_url }}" type="audio/wav">
        Your browser does not support the audio element.
      </audio>
      <div style="margin-top:0.6rem; font-size:0.85rem; color:#94a3b8;">Audio placeholder: <code>/assets/audio/example_bat_call.wav</code></div>
    </div>
  </div>
</div> -->

---

## Workflow snapshot

1. **Select devices** → choose input/output, sample rates, frame size.
2. **Probe** by selecting a device (RUBAT logs attempts and capabilities).
3. **Choose channels** (scrollable input/output grids).
4. **START** streaming.
5. Monitor in **Heterodyne** or **Passthrough**.
6. Record using:
   - **Tap** (pre+post)
   - **Continuous** (stream to disk)
   - **Auto** (threshold-triggered tap)

---

## Get started

<div style="display:grid; grid-template-columns:repeat(2, 1fr); gap:0.75rem; margin:0.75rem 0 0.25rem;">
  <a href="{{ '/download/' | relative_url }}" style="text-decoration:none;">
    <div style="padding:0.95rem; border-radius:14px; border:1px solid rgba(148,163,184,0.18); background:rgba(2,6,23,0.03);">
      <div style="font-weight:800; color:#0f172a;">⬇️ Download</div>
      <div style="margin-top:0.35rem; color:#475569; line-height:1.45;">Get the software package. As always, the application is free.</div>
    </div>
  </a>
  <a href="{{ '/install/' | relative_url }}" style="text-decoration:none;">
    <div style="padding:0.95rem; border-radius:14px; border:1px solid rgba(148,163,184,0.18); background:rgba(2,6,23,0.03);">
      <div style="font-weight:800; color:#0f172a;">📦 Install</div>
      <div style="margin-top:0.35rem; color:#475569; line-height:1.45;">MATLAB Runtime / packaged app install, and setup.</div>
    </div>
  </a>
  <a href="{{ '/quickstart/' | relative_url }}" style="text-decoration:none;">
    <div style="padding:0.95rem; border-radius:14px; border:1px solid rgba(148,163,184,0.18); background:rgba(2,6,23,0.03);">
      <div style="font-weight:800; color:#0f172a;">🚀 Quickstart Guide</div>
      <div style="margin-top:0.35rem; color:#475569; line-height:1.45;">Set up the tool and get to your first recording and start collecting data!</div>
    </div>
  </a>
  <a href="{{ '/tips/' | relative_url }}" style="text-decoration:none;">
    <div style="padding:0.95rem; border-radius:14px; border:1px solid rgba(148,163,184,0.18); background:rgba(2,6,23,0.03);">
      <div style="font-weight:800; color:#0f172a;">💡 Tips & Best Practices</div>
      <div style="margin-top:0.35rem; color:#475569; line-height:1.45;">Practical guide to avoiding common mistakes and becoming a bioacoustic field champ!</div>
    </div>
  </a>
</div>

---

## Open science

RUBAT Studio is developed with an open-science mindset:

- transparent, reproducible signal-processing choices
- clear documentation of acquisition parameters
- a workflow designed to be shared, reviewed, and extended


<!-- Lightbox Modal (shared by all images on this page) -->
<div id="rbModal" class="rb-modal" onclick="rbClose()">
  <span class="rb-close" aria-label="Close">&times;</span>
  <img class="rb-modal-content" id="rbModalImg" alt="">
  <div class="rb-modal-caption" id="rbModalCap"></div>
</div>

<script>
  function rbOpen(img){
    var modal = document.getElementById("rbModal");
    var modalImg = document.getElementById("rbModalImg");
    var modalCap = document.getElementById("rbModalCap");

    modal.style.display = "block";
    modalImg.src = img.src;
    modalImg.alt = img.alt || "";

    // Use alt text as a simple caption (optional)
    modalCap.textContent = img.alt || "";
  }

  function rbClose(){
    document.getElementById("rbModal").style.display = "none";
  }

  // Close on Escape
  document.addEventListener("keydown", function(e){
    if(e.key === "Escape"){
      rbClose();
    }
  });
</script>