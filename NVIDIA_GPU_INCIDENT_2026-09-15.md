# NVIDIA KMS mapping failure — 2026-09-15

## Confirmed failure

At 00:20:30 CEST, Chrome's `Media` process entered NVIDIA's DRM/KMS path
while using hardware-accelerated media. The NVIDIA 580.178.04 driver requested
a write-combining CPU mapping for video memory, but Linux rejected it because
the same physical range already had an uncached-minus mapping:

```text
x86/PAT: Media:58288 conflicting memory types ef740000-f0160000
         uncached-minus<->write-combining
x86/PAT: memtype_reserve failed ... -16
[nvidia-drm] Failed to ioremap_wc NvKmsKapiMemory
```

The failed range crosses the GTX 1070's 256 MiB BAR1 aperture
(`e0000000–efffffff`) into BAR3 (`f0000000–f1ffffff`). The installed NVIDIA
DRM source performs exactly this sequence: `mapMemory(... USER)` followed by
`ioremap_wc(physical_address, size)`.

Immediately afterward, the driver emitted a GPU-wide Xid-32 storm. Hyprland,
Xwayland, Chrome, Steam, ChatGPT, Code, YouTube Music, Ghostty, and
`nvidia-persistenced` were affected. Hyprland then saw
`GL_GUILTY_CONTEXT_RESET` and aborted; it did not initiate the fault.

## Conclusion

This is an NVIDIA 580-series Wayland/KMS video-memory mapping failure triggered
by Chromium hardware-accelerated media on a non-ReBAR GTX 1070. The most likely
underlying condition is exhaustion or fragmentation of the card's small BAR1
mapping window. That condition is supported by the failed cross-BAR request and
matching NVIDIA reports, but is not emitted as an explicit local driver error;
it remains an inference rather than a proven allocation counter.

No event-time OOM, IOMMU fault, PCIe AER/MCE, thermal event, or GPU disconnect
was recorded. The PCIe link is separately downtrained to Gen1 ×16 despite
Gen3 capability; that deserves hardware/firmware investigation but is not
established as the cause of this crash.

The computer was shut down by a physical power-key press at 00:21:32, not by
Hyprland.

## References

- Linux PAT documentation: https://docs.kernel.org/6.3/x86/pat.html
- NVIDIA Xid reference: https://docs.nvidia.com/deploy/xid-errors/archive/index.html
- Matching NVIDIA forum report: https://forums.developer.nvidia.com/t/bug-report-wayland-only-dmaallocmapping-gm107-va-mapping-failures-does-not-reproduce-on-x11/353598
