#!/usr/bin/env python3
"""
Mochaccino
Author: MihaiStreames (2026)

Generate 16 ANSI terminal colors from Material You palette.

Takes a wallpaper, extracts Material You colors via matugen,
generates a perceptually balanced 16-color ANSI palette,
then runs matugen with the injected palette for template rendering.

Usage: mochaccino.py <image_path> [--config <config.toml>]
"""

import colorsys
import json
from pathlib import Path
import subprocess
import sys


def hex_to_rgb(h: str) -> tuple[float, float, float]:
    h = h.lstrip("#")
    r = int(h[0:2], 16) / 255.0
    g = int(h[2:4], 16) / 255.0
    b = int(h[4:6], 16) / 255.0
    return r, g, b


def rgb_to_hex(r: float, g: float, b: float) -> str:
    return f"#{int(round(r * 255)):02x}{int(round(g * 255)):02x}{int(round(b * 255)):02x}"


def rgb_to_hsv(r: float, g: float, b: float) -> tuple[float, float, float]:
    return colorsys.rgb_to_hsv(r, g, b)


def hsv_to_rgb(h: float, s: float, v: float) -> tuple[float, float, float]:
    return colorsys.hsv_to_rgb(h, s, v)


def _linearize(c: float) -> float:
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def rgb_to_xyz(r: float, g: float, b: float) -> tuple[float, float, float]:
    rl, gl, bl = _linearize(r), _linearize(g), _linearize(b)
    x = 0.4124564 * rl + 0.3575761 * gl + 0.1804375 * bl
    y = 0.2126729 * rl + 0.7151522 * gl + 0.0721750 * bl
    z = 0.0193339 * rl + 0.1191920 * gl + 0.9503041 * bl
    return x, y, z


def xyz_to_lab(x: float, y: float, z: float) -> tuple[float, float, float]:
    xn, yn, zn = 0.95047, 1.0, 1.08883

    def f(t: float) -> float:
        return t ** (1 / 3) if t > 0.008856 else 7.787 * t + 16 / 116

    fx, fy, fz = f(x / xn), f(y / yn), f(z / zn)
    l_star = 116 * fy - 16
    a = 500 * (fx - fy)
    b = 200 * (fy - fz)
    return l_star, a, b


def rgb_to_lstar(r: float, g: float, b: float) -> float:
    return xyz_to_lab(*rgb_to_xyz(r, g, b))[0]


def delta_phi_star(l1: float, l2: float) -> float:
    """Attempt at DPS-like contrast, using L* difference scaled"""
    return abs(l1 - l2)


def adjust_lstar(
    h: float, s: float, v: float, bg_lstar: float, target: float, lighten: bool
) -> tuple[float, float, float]:
    """Adjust value to meet contrast target against background"""
    best_v = v
    best_diff = abs(delta_phi_star(rgb_to_lstar(*hsv_to_rgb(h, s, v)), bg_lstar) - target)

    step = 0.01

    for i in range(100):
        test_v = v + (step * i if lighten else -step * i)
        test_v = max(0.0, min(1.0, test_v))
        r, g, b = hsv_to_rgb(h, s, test_v)
        lstar = rgb_to_lstar(r, g, b)
        diff = abs(delta_phi_star(lstar, bg_lstar) - target)

        if diff < best_diff:
            best_diff = diff
            best_v = test_v

        if best_diff < 1.0:
            break

    return h, s, best_v


def adjust_bidirectional(
    h: float, s: float, v: float, bg_lstar: float, target: float
) -> tuple[float, float, float]:
    """Try both lighter and darker, pick closest to original"""
    _, _, v_light = adjust_lstar(h, s, v, bg_lstar, target, lighten=True)
    _, _, v_dark = adjust_lstar(h, s, v, bg_lstar, target, lighten=False)

    if abs(v_light - v) <= abs(v_dark - v):
        return h, s, v_light

    return h, s, v_dark


def blend_hue(base_hue: float, primary_hue: float, amount: float) -> float:
    """Blend base_hue toward primary_hue by amount (0-1)"""
    diff = primary_hue - base_hue
    if diff > 0.5:
        diff -= 1.0
    elif diff < -0.5:
        diff += 1.0

    result = base_hue + diff * amount
    return result % 1.0


def derive_container(primary_hex: str, is_light: bool = False) -> str:
    """Derive a container color from primary"""
    r, g, b = hex_to_rgb(primary_hex)
    h, s, v = rgb_to_hsv(r, g, b)

    if is_light:
        v = min(v * 1.77, 1.0)
        s = s * 0.32
    else:
        v = v * 0.463
        s = min(s * 1.834, 1.0)

    return rgb_to_hex(*hsv_to_rgb(h, s, v))


NORMAL_TARGET = 40.0
SECONDARY_TARGET = 35.0
ACCENT_TARGET = 24.5
DIM_TARGET = 17.5


def generate_palette(primary_hex: str, surface_hex: str) -> dict[str, str]:
    """Generate 16 ANSI colors from primary + surface"""
    pr, pg, pb = hex_to_rgb(primary_hex)
    ph, ps, pv = rgb_to_hsv(pr, pg, pb)

    sr, sg, sb = hex_to_rgb(surface_hex)
    bg_lstar = rgb_to_lstar(sr, sg, sb)

    cr, cg, cb = hex_to_rgb(derive_container(primary_hex, False))
    ch, _, _ = rgb_to_hsv(cr, cg, cb)

    base_sat = max(ps, 0.5)
    base_val = max(pv, 0.5)

    red_h = blend_hue(0.0, ph, 0.12)
    green_h = blend_hue(0.33, ph, 0.10)
    yellow_h = blend_hue(0.14, ph, 0.04)

    def clamp(x: float) -> float:
        return max(0.0, min(1.0, x))

    def make_color(h: float, s: float, v: float, target: float, bidirectional: bool = False) -> str:
        if bidirectional:
            h2, s2, v2 = adjust_bidirectional(h, s, v, bg_lstar, target)
        else:
            h2, s2, v2 = adjust_lstar(h, s, v, bg_lstar, target, lighten=True)

        return rgb_to_hex(*hsv_to_rgb(h2, clamp(s2), clamp(v2)))

    palette = {}

    # color0: background (surface)
    palette["color0"] = surface_hex
    # color8: bright black (comments/dim)
    palette["color8"] = make_color(ch, base_sat * 0.15, base_val * 0.65, SECONDARY_TARGET)

    # color1/9: red
    palette["color1"] = make_color(
        red_h, clamp(base_sat * 1.1), clamp(base_val * 1.15), NORMAL_TARGET
    )
    palette["color9"] = make_color(
        red_h, clamp(base_sat * 0.75), clamp(base_val * 1.35), ACCENT_TARGET, True
    )

    # color2/10: green
    palette["color2"] = make_color(
        green_h, clamp(base_sat * 1.0), clamp(base_val * 1.0), NORMAL_TARGET
    )
    palette["color10"] = make_color(
        green_h, clamp(base_sat * 0.7), clamp(base_val * 1.2), ACCENT_TARGET, True
    )

    # color3/11: yellow
    palette["color3"] = make_color(
        yellow_h, clamp(base_sat * 1.1), clamp(base_val * 1.25), NORMAL_TARGET
    )
    palette["color11"] = make_color(
        yellow_h, clamp(base_sat * 0.7), clamp(base_val * 1.5), ACCENT_TARGET, True
    )

    # color4/12: blue (primary-based)
    palette["color4"] = make_color(ph, clamp(ps * 1.2), pv * 0.95, NORMAL_TARGET)
    palette["color12"] = make_color(ph, ps * 0.85, clamp(pv * 1.1), ACCENT_TARGET, True)

    # color5: magenta (primary container)
    palette["color5"] = derive_container(primary_hex, False)
    # color13: bright magenta (pastel primary)
    palette["color13"] = rgb_to_hex(*hsv_to_rgb(ph, ps * 0.7, clamp(pv * 1.3)))

    # color6: cyan (exact primary)
    palette["color6"] = primary_hex
    # color14: bright cyan (light primary tint)
    palette["color14"] = rgb_to_hex(*hsv_to_rgb(ph, ps * 0.45, clamp(pv * 1.4)))

    # color7: white (foreground)
    palette["color7"] = make_color(ch, base_sat * 0.12, clamp(base_val * 1.05), NORMAL_TARGET)
    # color15: bright white
    palette["color15"] = make_color(ch, base_sat * 0.05, clamp(base_val * 1.45), NORMAL_TARGET)

    return palette


def palette_to_json(palette: dict[str, str]) -> str:
    """Convert palette dict to matugen --import-json-string format"""
    data: dict[str, dict[str, dict[str, dict[str, str]]]] = {"mochaccino": {}}
    for name, hex_color in palette.items():
        stripped = hex_color.lstrip("#")
        data["mochaccino"][name] = {
            "default": {"hex": hex_color, "hex_stripped": stripped},
            "dark": {"hex": hex_color, "hex_stripped": stripped},
            "light": {"hex": hex_color, "hex_stripped": stripped},
        }
    return json.dumps(data)


def get_matugen_colors(image_path: str, config_path: str | None = None) -> dict[str, dict[str, dict[str, str]]]:
    """Run matugen in dry-run mode and capture Material You colors"""
    cmd = ["matugen", "image", image_path, "--json", "hex", "--dry-run"]

    if config_path:
        cmd.extend(["--config", config_path])

    result = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if result.returncode != 0:
        print(f"matugen failed: {result.stderr}", file=sys.stderr)
        sys.exit(1)

    colors: dict[str, dict[str, dict[str, str]]] = json.loads(result.stdout)
    return colors


def run_matugen_with_palette(image_path: str, config_path: str, palette_json: str) -> None:
    """Run matugen with injected mochaccino palette"""
    cmd = [
        "matugen",
        "image",
        image_path,
        "--config",
        config_path,
        "--import-json-string",
        palette_json,
    ]

    result = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if result.returncode != 0:
        print(f"matugen failed: {result.stderr}", file=sys.stderr)
        sys.exit(1)


def main() -> None:
    if len(sys.argv) < 2:
        print(
            f"Usage: {sys.argv[0]} <image_path> [--config <config.toml>]",
            file=sys.stderr,
        )
        sys.exit(1)

    image_path = sys.argv[1]
    script_dir = Path(__file__).parent
    config_path = str(script_dir / "config.toml")

    for i, arg in enumerate(sys.argv):
        if arg == "--config" and i + 1 < len(sys.argv):
            config_path = sys.argv[i + 1]

    data = get_matugen_colors(image_path, config_path)
    colors = data["colors"]

    primary_hex = colors["primary"]["default"]
    surface_hex = colors["surface"]["default"]

    palette = generate_palette(primary_hex, surface_hex)
    palette_json = palette_to_json(palette)
    run_matugen_with_palette(image_path, config_path, palette_json)


if __name__ == "__main__":
    main()
