---
layout: default
title: FAQ
permalink: /faq/
nav_order: 6
---


# FAQ

---

## 1. Is RUBAT free? Are there premium features?

Yes — RUBAT is completely free.

There are no premium tiers, locked features, or paid upgrades. All functionality — multichannel recording, heterodyne monitoring, auto-triggered recording, calibration support, and logging — is available to everyone.

RUBAT is developed under an open-science philosophy and is intended to lower the barrier to high-quality bioacoustic data collection.

---

## 2. What kind of sound cards is RUBAT compatible with?

RUBAT relies on the operating system’s audio subsystem.

If your operating system detects the device and the necessary drivers are installed, RUBAT is designed to:

- Detect the device automatically
- Validate available input/output channels
- Query supported sampling rates
- Probe usable frame sizes and configurations

This includes external USB audio interfaces, professional sound cards, and USB microphones. If the device works in your OS, RUBAT is designed to work with it.

---

## 3. What is special about RUBAT?

RUBAT is designed specifically for bioacoustic data collection.

Whether you are recording bats, birds, insects, or any other signal that can be digitised via a standard audio interface, RUBAT provides a dedicated scientific interface for high-frequency acquisition.

### Design and Implementation

One of the primary design goals was to expose all relevant audio control parameters — sampling rate, channel count, frame size, bit depth — in a single unified interface.

These are typically scattered across:

- Proprietary audio software
- Operating system audio panels
- Custom MATLAB scripts

RUBAT consolidates everything into structured panels and combines this control with:

- Multiple recording modes (Tap, Continuous, Auto)
- Live heterodyne monitoring
- Real-time waveform display
- Dual spectrogram views
- Structured logging of every parameter change

This provides full transparency and control over multichannel recording in a single application.

## 4. Can I use it for general recording?

Although RUBAT Studio is built for ultrasonic bioacoustics, it’s fundamentally a high-quality multichannel recorder — so you can use it for other audio projects too.

If your interface presents standard studio inputs/outputs, RUBAT can record music, voice, and instruments just like a conventional DAW capture rig:

- Cover songs / overdubs: route a backing track into one input (or a spare interface channel) and record your vocal (or instrument) on another channel. You’ll end up with clean, separate tracks you can mix later.
- Live sessions: plug each instrument (or mic) into its own input channel and record everything simultaneously — perfect for rehearsals, demos, and “one-take” performances.
- Clip capture + organised takes: use the file suffix to tag takes (song name, tempo, take number), then edit and mix later in your preferred audio software.

In short: if your sound card can see it, RUBAT can capture it — reliably, with clear channel separation and reproducible session settings.

---

## 5. What is heterodyne monitoring?

Bats emit ultrasonic calls that are typically beyond human hearing (above 20 kHz).

Heterodyne monitoring works by:

1. Mixing the incoming ultrasonic signal with a selectable carrier frequency
2. Shifting the ultrasonic energy down into the audible range

This allows you to *hear* the presence and activity of bats in real time.

It is particularly useful in the field, because:

- You immediately know whether bats are active
- You can adjust microphone positioning live
- You can verify that signals are being captured properly

The original ultrasonic signal remains unchanged in the recorded WAV file — heterodyning only affects the monitoring output.

---

## 6. What is the use of auto threshold-triggered recording?

Auto mode is designed for activity-based recording.

Imagine deploying the system in the field where activity is intermittent. Instead of recording continuously for hours, RUBAT can:

- Monitor signal amplitude
- Count threshold-crossing events within the last pre-trigger window
- Automatically save a recording when sufficient activity is detected

This dramatically reduces:

- Disk usage
- Manual sorting time
- Post-processing workload

While it does not guarantee that only target species are recorded, careful threshold setup makes it highly effective — particularly for bat echolocation calls.

---

## 7. Can I use a USB microphone such as an Ultramic?

Yes.

The Ultramic 384K has been tested with RUBAT and works well.

Any USB audio input device that:

- Is detected by your operating system
- Has properly installed drivers

should appear in the Device Selection panel and can be used for recording.

---

## 8. Can I use multiple audio interfaces?

Yes.

RUBAT allows you to:

- Record from one audio device
- Monitor from another

This is particularly useful for:

- Networked audio setups
- Remote microphone deployments
- Situations where the sound card is located in one room and monitoring happens in another

For example, you can record ultrasonic data from a field interface while listening to heterodyne output through your computer speakers.

---

## 9. How many channels can I record?

RUBAT queries all available channels from the selected input device.

Most standard audio interfaces provide:

- 2–8 input channels
- 2–4 output channels

If your interface supports more channels, they will appear in the Channel Selection panel.

You can:

- Select specific channels for recording
- Use selected channels for monitoring
- Visualise selected channels in waveform and spectrogram views

The system dynamically adapts to the hardware capabilities.

---

## 10. Where are the files saved?

By default, RUBAT saves recordings to:

```
Documents/RUBAT/Rec/YYYYMMDD/
```

This means:

- A RUBAT folder is created automatically
- Recordings are grouped by date
- Files are automatically time-stamped

This structure keeps long-term data collection organised and reproducible.

---

## 11. Can I add a suffix to the file name?

Yes.

All recordings are automatically time-stamped. You can optionally add a custom suffix in the Recording panel.

This is particularly useful when collecting multiple datasets in the same day.

For example:

- Morning: finches
- Evening: bats

Adding a suffix makes downstream sorting and analysis much easier.

---

## 12. Do I need expert knowledge of audio processing to use RUBAT?

No.

Each control includes tooltips explaining its function.

While some familiarity with sampling rate, channels, and signal levels is helpful, you do not need to be an expert sound engineer to use RUBAT.

The motivation for RUBAT comes from years of collecting terabytes of data using custom MATLAB scripts across multiple projects. Setting up new students with bespoke scripts often required specialist knowledge.

RUBAT provides a structured, accessible interface so that:

- New users can get started quickly
- Multichannel recording is standardised
- Data collection becomes more robust and reproducible

As long as you understand the basic concepts of digital audio acquisition, RUBAT is designed to guide you through the rest.

---

## 13. Was this project publicly funded by an agency?

No.

RUBAT is a self-funded project created out of a personal passion for acoustics and research into bat echolocation.

It was developed independently to support robust, reproducible bioacoustic data collection in both laboratory and field environments.

---

## 14. Where can I find the scientific literature associated with RUBAT?

Scientific descriptions and related methodological papers can be found on bioRxiv.

👉 [View related publications on bioRxiv](https://www.biorxiv.org/)  
*(Placeholder — replace with specific RUBAT preprint link)*

These publications describe the design rationale, implementation details, and validation experiments associated with the system.

---

## 15. How can I support the project?

If you find RUBAT useful and would like to support continued development, you may consider buying me a coffee.

👉 [Buy me a coffee](https://buymeacoffee.com/raviumadi)  


Support is entirely optional. The software will always remain free and openly available.
