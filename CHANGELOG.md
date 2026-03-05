# Changelog

All notable changes to the **Spatium** project will be documented in this file.

## [0.1.0] - 2024-05-22
### Added
- **Core Logic**: Full implementation of virtual desktop switching using `TaskManager.VirtualDesktopInfo`.
- **Customization**: Added configuration interface for dot sizes, active width/height, and spacing.
- **Hex Color Support**: Users can now input custom Hex codes or color names for active/inactive dots.
- **Animations**: Smooth `NumberAnimation` and `ColorAnimation` transitions between desktop states.
- **Mouse Interaction**: 
    - Click to switch desktop.
    - Mouse wheel scrolling with optional wrap-around logic.
- **Context Menu**: Added actions to add/remove virtual desktops and open System Settings.
- **Packaging**: Standard Plasma 6 directory structure with `metadata.json` in root.
- **Developer Tools**: Included `install.sh` for easy local deployment.

---

## [Planned for 0.2.0]
- **Tooltips**: Show desktop names on hover.
- **Drag & Drop**: Support moving windows between desktops via the dots.
- **Multi-screen Support**: Improved behavior for multi-monitor setups.
- **KGlobalAccel**: Configurable keyboard shortcuts for quick navigation.