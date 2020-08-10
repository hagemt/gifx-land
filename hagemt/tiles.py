#!/usr/bin/env python3
from time import sleep
import lifxlan

X = (0, 0, 0, 0) # BLACK
_ = tuple(lifxlan.WHITE)

def row_rotate(old_matrix):
    new_matrix = [old_matrix[-1]]
    for row in old_matrix[:-1]: new_matrix.append(row)
    return new_matrix

def row_setup(columns, rows):
    color_rows = []
    for r in range(rows):
        #hue = int(65535.0 * r / rows)
        #row = ((hue, 65535, 65535, 4500),) * columns
        row = tuple(X if (c + r) % 2 == 1 else _ for c in range(columns))
        color_rows.append(row)
    return color_rows

def project_matrix(tile_chain, color_rows, duration_s=1):
    duration_ms, rapid = int(float(duration_s) / 1000), duration_s <= 1
    tile_chain.project_matrix(color_rows, duration_ms, rapid=rapid)

def loop(tile_chain, duration_s = 0.5, colors_after=None):
    try:
        (columns, rows) = tile_chain.get_canvas_dimensions()
        color_rows = row_setup(columns, rows)
        while True:
            project_matrix(tile_chain, color_rows, duration_s=duration_s)
            sleep(max(duration_s, 0.05)) # max: 20Hz
            color_rows = row_rotate(color_rows)
    except KeyboardInterrupt:
        if colors_after:
            tile_chain.set_tilechain_colors(colors_after, rapid=True)

def main():
    import sys
    def debug(*args, **kwargs):
        print(*args, **kwargs, file=sys.stderr)

    lifx_lights = lifxlan.LifxLAN(2) # I happen to own two devices
    tile_chains = lifx_lights.get_tilechain_lights()
    if len(tile_chains) == 0:
        debug('[ERROR] found no tile chain lights')
        sys.exit(1)

    tile_chain, = tile_chains # just use the first tile chain discovered
    debug('[TRACE] found tile chain named: {}'.format(tile_chain.get_label()))
    original_colors = tile_chain.get_tilechain_colors()
    loop(tile_chain, colors_after=original_colors)

if __name__ == '__main__':
    main()
