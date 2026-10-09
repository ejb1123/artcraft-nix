# Libraries the apps dlopen at runtime (winit/wgpu windowing + graphics, dbus for portals).
# The release binaries only link libc/libgcc, so these must be put on the rpath explicitly.
{
  dbus,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  vulkan-loader,
  wayland,
}:
[
  dbus
  libGL
  libx11
  libxcb
  libxcursor
  libxi
  libxkbcommon
  libxrandr
  vulkan-loader
  wayland
]
