---
layout: default
title: RUBAT Studio
permalink: /
nav_order: 1
description: Live audio-visual monitoring and high-fidelity multichannel recording for field bioacoustics.
---

# Realtime Unified BioAcoustic Tool

<section class="rubat-home-hero">
  <div class="rubat-home-hero__media">
    <img src="{{ '/assets/home/img/rubat_firstview.png' | relative_url }}"
         alt="RUBAT Studio interface overview"
         class="rb-zoom"
         onclick="rbOpen(this)">
  </div>

  <div class="rubat-home-hero__copy">
    <p class="eyebrow-label">Sounds and Senses Lab</p>
    <h2>Live audio-visual monitoring and high-fidelity multichannel recording</h2>
    <p>
      RUBAT Studio is a MATLAB-based recorder for field bioacoustics and multichannel acquisition.
      It pairs high-sample-rate capture with real-time heterodyne monitoring, responsive visualisation,
      and robust recording workflows that feel at home within the BiosoniX family.
    </p>

    <ul class="rubat-chip-list">
      <li><span class="rubat-chip">Flexible workflows</span></li>
      <li><span class="rubat-chip">Realtime monitoring</span></li>
      <li><span class="rubat-chip">Tap / Continuous / Auto</span></li>
      <li><span class="rubat-chip">Multichannel audio streams</span></li>
      <li><span class="rubat-chip">Record any sound</span></li>
    </ul>
  </div>
</section>

---

<div class="rubat-action-row">
  <a class="button-pill button-pill--primary" href="https://github.com/raviumadi/RUBAT-Recorder/releases/download/R1.0/rubat_web_macos.zip">⬇ Download for macOS</a>
  <a class="button-pill button-pill--primary" href="https://github.com/raviumadi/RUBAT-Recorder/releases/download/R1.0/rubat_web_win64.exe.zip">⬇ Download for Windows</a>
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

<section class="rubat-pronounce">
  <h3>How to pronounce “RUBAT”</h3>
  <p>
    Say it like <strong>“Rue-BAT”</strong>. “Rue” rhymes with <strong>“blue”</strong>, then “bat”.
  </p>
  <p class="rubat-phonetics"><strong>Phonetic:</strong> <code>ROO-bat</code> · <strong>IPA:</strong> <code>/ˈruː.bæt/</code></p>
  <audio controls>
    <source src="{{ '/assets/home/audio/rubat_pronunciation.wav' | relative_url }}" type="audio/wav">
    Your browser does not support the audio element.
  </audio>
</section>

---

## Key capabilities

<div class="rubat-feature-grid">
  <article class="rubat-feature-card">
    <div class="rubat-feature-card__media">
      <video class="rubat-hover-video" muted loop playsinline>
        <source src="{{ '/assets/home/video/heterodyne.mp4' | relative_url }}" type="video/mp4">
      </video>
    </div>
    <h3>Continuous monitoring</h3>
    <p>Shift bat calls into the audible range with continuously accumulated heterodyne phase, with no clicks or frame-boundary discontinuities. Switch freely between <strong>Off</strong>, <strong>Passthrough</strong>, and <strong>Heterodyne</strong> while the stream is live.</p>
  </article>

  <article class="rubat-feature-card">
    <div class="rubat-feature-card__media">
      <video class="rubat-hover-video" muted loop playsinline>
        <source src="{{ '/assets/home/video/feature_channels.mp4' | relative_url }}" type="video/mp4">
      </video>
    </div>
    <h3>True N-channel routing</h3>
    <p>Each selected input channel can route one-to-one to matching physical outputs. A per-channel mask keeps monitoring predictable, while <strong>Mix mode</strong> gives intuitive left-right headphone monitoring of an array.</p>
  </article>

  <article class="rubat-feature-card">
    <div class="rubat-feature-card__media">
      <video class="rubat-hover-video" muted loop playsinline>
        <source src="{{ '/assets/home/video/feature_tap.mp4' | relative_url }}" type="video/mp4">
      </video>
    </div>
    <h3>Ring buffer tap capture</h3>
    <p>A continuously written buffer keeps the last N seconds of audio ready at all times. Press <strong>TAP</strong> to recover what happened just before the moment you reacted.</p>
  </article>

  <article class="rubat-feature-card">
    <div class="rubat-feature-card__media">
      <video class="rubat-hover-video" muted loop playsinline>
        <source src="{{ '/assets/home/video/feature_auto.mp4' | relative_url }}" type="video/mp4">
      </video>
    </div>
    <h3>Auto mode for unattended runs</h3>
    <p>Arm <strong>Auto</strong> and let lightweight threshold detection fire retrospective tap captures on its own, ideal for long deployments and low-overhead field use.</p>
  </article>

  <article class="rubat-feature-card">
    <div class="rubat-feature-card__media">
      <video class="rubat-hover-video" muted loop playsinline>
        <source src="{{ '/assets/home/video/feature_spl.mp4' | relative_url }}" type="video/mp4">
      </video>
    </div>
    <h3>Calibrated waveform display</h3>
    <p>Provide a sensitivity calibration factor and the waveform panel switches to <strong>dB SPL re 20 µPa</strong>. Without calibration, RUBAT still offers a reliable relative dBFS view.</p>
  </article>

  <article class="rubat-feature-card">
    <div class="rubat-feature-card__media">
      <video class="rubat-hover-video" muted loop playsinline>
        <source src="{{ '/assets/home/video/feature_spec.mp4' | relative_url }}" type="video/mp4">
      </video>
    </div>
    <h3>Dual greyscale spectrograms</h3>
    <p>Monitor two independently assigned channels with high-contrast spectrograms that remain readable outdoors, in twilight, or during rapid operator checks.</p>
  </article>

  <article class="rubat-feature-card">
    <div class="rubat-feature-card__media">
      <video class="rubat-hover-video" muted loop playsinline>
        <source src="{{ '/assets/home/video/feature_logging.mp4' | relative_url }}" type="video/mp4">
      </video>
    </div>
    <h3>Robust device handling</h3>
    <p>Input-output channel counts are queried and validated, device controls lock during streaming, and the application writes events to a live log for reliable troubleshooting.</p>
  </article>

  <article class="rubat-feature-card">
    <h3>Three recording modes</h3>
    <p><strong>Tap</strong> captures a retrospective clip, <strong>Continuous</strong> streams directly to disk, and <strong>Auto</strong> arms threshold-based triggers. Keyboard shortcuts keep the workflow fast once you are in the field.</p>
  </article>
</div>

---

## Example recording

<section class="rubat-example">
  <p class="eyebrow-label">Field testing</p>
  <h3>Two-channel example recording</h3>
  <video controls id="fieldVideo">
    <source src="{{ '/assets/home/video/spectrogram_video_20260227_133734_147.mp4' | relative_url }}" type="video/mp4">
    Your browser does not support the video element.
  </video>
</section>

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

<div class="rubat-quick-links">
  <a class="rubat-link-card" href="{{ '/download/' | relative_url }}"><strong>⬇ Download</strong><span>Get the software package. The application is free to use.</span></a>
  <a class="rubat-link-card" href="{{ '/install/' | relative_url }}"><strong>📦 Install</strong><span>MATLAB Runtime or packaged app installation and setup notes.</span></a>
  <a class="rubat-link-card" href="{{ '/quickstart/' | relative_url }}"><strong>🚀 Quickstart</strong><span>Move from installation to your first recording session quickly.</span></a>
  <a class="rubat-link-card" href="{{ '/tips/' | relative_url }}"><strong>💡 Tips &amp; best practices</strong><span>A practical guide to more reliable field and studio workflows.</span></a>
</div>

---

## Open science

<section class="rubat-open-science">
  <p>RUBAT Studio is developed with an open-science mindset:</p>
  <ul>
    <li>transparent, reproducible signal-processing choices</li>
    <li>clear documentation of acquisition parameters</li>
    <li>a workflow designed to be shared, reviewed, and extended</li>
  </ul>
</section>


<!-- Lightbox Modal (shared by all images on this page) -->
<div id="rbModal" class="rb-modal" onclick="rbClose()">
  <span class="rb-close" aria-label="Close">&times;</span>
  <img class="rb-modal-content" id="rbModalImg" alt="">
  <div class="rb-modal-caption" id="rbModalCap"></div>
</div>

<script>
  document.querySelectorAll('.rubat-hover-video').forEach(function (video) {
    video.addEventListener('mouseenter', function () {
      video.play();
    });

    video.addEventListener('mouseleave', function () {
      video.pause();
      video.currentTime = 0;
    });
  });

  var fieldVideo = document.getElementById('fieldVideo');
  if (fieldVideo) {
    fieldVideo.volume = 0.5;
  }

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