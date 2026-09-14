# NVIDIA Wayland/KMS incident — 2026-09-15

## Summary

At 00:20:30 CEST, the proprietary NVIDIA driver's Wayland/KMS mapping path
failed while a Chromium Media process was active. This triggered a GPU-wide
Xid-32 storm which affected Hyprland and every active GPU client. Hyprland
detected a lost OpenGL context and deliberately aborted. The desktop session
then collapsed. The computer was subsequently shut down by a short physical
power-key press at 00:21:32; it was not powered off automatically by Hyprland.

## Environment

| Component | Value |
| --- | --- |
| OS | Debian GNU/Linux forky/sid |
| Kernel | 6.19.14+deb14-amd64 |
| GPU | NVIDIA GeForce GTX 1070 (GP104) |
| Driver | NVIDIA proprietary 580.178.04-1 |
| Compositor | Hyprland 0.55.4+ds-2+b1 |
| Display driver | `nvidia`, `nvidia_drm` |
| BAR1 aperture | 256 MiB |

## Timeline (CEST)

| Time | Evidence | Meaning |
| --- | --- | --- |
| 00:20:30 | `x86/PAT` reports conflicting UC-/WC memory types for `Media` | A Chromium Media process attempted a GPU memory mapping that failed. |
| 00:20:30 | `nvidia-drm` fails `ioremap_wc NvKmsKapiMemory` | NVIDIA's KMS mapping path fails. |
| 00:20:30 | 181 `NVRM: Xid ... 32` records | GPU-wide fault storm impacts `Hyprland`, Xwayland, Chromium, ChatGPT, Steam, YouTube Music, VS Code, and Ghostty. |
| 00:20:30 | Hyprland writes crash report | `glGetGraphicsResetStatus` returns `GL_GUILTY_CONTEXT_RESET`; Hyprland exits via `SIGABRT`. |
| 00:20:31 | `nvidia-drm` fails to map `NvKmsKapiMemory`; Chrome Media takes SIGILL | Downstream Chromium failure after the NVIDIA resource failure. |
| 00:20:50 | Steam reports a stalled main loop | Downstream effect after the compositor/GPU failure. |
| 00:21:10 | NVIDIA Xid 66 for YouTube Music | GPU remains unhealthy. |
| 00:21:32 | `systemd-logind`: `Power key pressed short` | User-initiated, orderly shutdown begins. |

## Key kernel excerpts

```text
x86/PAT: Media:<pid> conflicting memory types ... uncached-minus<->write-combining
x86/PAT: memtype_reserve failed ... track write-combining, req write-combining
ioremap memtype_reserve failed -16
[drm] [nvidia-drm] ... Failed to ioremap_wc NvKmsKapiMemory <redacted>
NVRM: Xid (PCI:0000:01:00): 32 ... name=Hyprland
NVRM: Xid (PCI:0000:01:00): 32 ... name=Xwayland
NVRM: Xid (PCI:0000:01:00): 32 ... name=chrome
NVRM: Xid (PCI:0000:01:00): 32 ... name=steam
NVRM: Xid (PCI:0000:01:00): 32 ... name=ghostty
[drm:__nv_drm_gem_nvkms_map [nvidia_drm]] *ERROR* ... Failed to map NvKmsKapiMemory <redacted>
traps: Media[<pid>] trap invalid opcode ... in chrome
```

## Scope and recurrence

This is not isolated to Hyprland, Steam, Ghostty/Phosphor, or a single client:
the same Xid-32 storm reached many unrelated GPU clients simultaneously.

Matching NVIDIA KMS/Xid-32 records in retained boot journals:

| Boot | Matching records |
| --- | ---: |
| 2026-09-14 → 2026-09-15 | 181 |
| Previous boot | 14 |
| Two boots prior | 1 |

No event-time host OOM, PCIe AER/MCE, thermal failure, or `GPU has fallen off
the bus` message was found. NVIDIA documents Xid 32 as a PBDMA/PCIe
communication-path error; it can indicate a driver, PCIe, or hardware issue.

## Assessment

The immediate failure is the NVIDIA Wayland/KMS memory-mapping path. Chromium
Media was the first identifiable active client in the fault sequence and is
the most likely trigger, particularly during hardware-accelerated video, but
the logs cannot prove it caused the driver defect. The concurrently running
Ghostty/Phosphor instance and Hyprland plugin are affected clients, not proven
causes.

The signature matches public reports of `memtype_reserve failed` and
`Failed to ioremap_wc/map NvKmsKapiMemory` followed by Chromium Media failure
and compositor resets on NVIDIA Wayland systems.

## Next diagnostics / mitigations

1. Update the full system, including the NVIDIA driver, kernel, Hyprland, and
   graphics stack; reboot into the new kernel.
2. Temporarily disable hardware acceleration in Chrome/Chromium and YouTube
   Music. If the incidents stop, this establishes the most useful trigger.
3. If faults persist, test another NVIDIA driver branch/kernel combination.
4. If they persist across software stacks, check/reseat the GPU, PCIe slot,
   and power connectors; Xid 32 can also reflect PCIe-link quality.

## References

- NVIDIA Xid documentation: https://docs.nvidia.com/deploy/xid-errors/archive/index.html
- NVIDIA forum report with the same Wayland/KMS mapping signature:
  https://forums.developer.nvidia.com/t/bug-report-wayland-only-dmaallocmapping-gm107-va-mapping-failures-does-not-reproduce-on-x11/353598
