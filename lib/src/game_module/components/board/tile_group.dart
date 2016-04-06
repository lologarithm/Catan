// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


class TileControlPaletteConfig extends ControlPaletteConfig {
  factory TileControlPaletteConfig(Tile tile, GameActions actions) {
    List<PaletteOption> options = [
      new PaletteOption('theme', () => print('change type')),
      new PaletteOption('cube', () => print('change roll')),
      new PaletteOption('remove', () => actions.removeTile(tile.key)),
    ];
    return new TileControlPaletteConfig._internal(options);
  }

  TileControlPaletteConfig._internal(List<PaletteOption> options) : super(options);
}


var TileGroup = react.registerComponent(() => new _TileGroup());
class _TileGroup extends w_flux.FluxComponent<GameActions, GameStore> {
  Tile get tile => props['tile'];

  @override
  List<w_flux.Store> redrawOn() {
    if (store is GameStore) return [store.boardStore];
    else return [];
  }

  render() {
    Point center = scaledPoint(tile.coordinate, store.boardStore.viewport);

    List children = new List();
    List<Point> hexPoints = ringOfPoints(center: center, radius: COORD_SPACING, count: 6);
    children.add(react.polygon({
      'points': new List<String>.from(hexPoints.map((hex) => '${hex.x},${hex.y}')).join(' '),
      'fill': tileTypeToColor(tile.type),
      'stroke': 'white',
      'strokeWidth': '2',
      'onMouseDown': _handleMouseDown,
      'onTouchStart': _handleTouchStart,
    }));

    // List<Point> pipPoints = ringOfPoints(center: center, radius: radius * 2 / 3, count: pipCount);
    List<Point> points = pipPoints(center: center, radius: COORD_SPACING * 0.5, count: chances(tile.roll));
    points.forEach((point) {
      children.add(react.circle({
        'cx': point.x,
        'cy': point.y,
        'r': 2,
        'fill': activeColor,
      }));
    });

    children.add(react.text({
      'textAnchor': 'middle',
      'x': center.x,
      'y': center.y,
      'dy': '.3em',
      'fill': activeColor,
      'style': {
        'pointerEvents': 'none',
        'fontSize': 20,
        'fontFamily': '"Century Gothic", CenturyGothic, AppleGothic, sans-serif',
      }
    }, '${tile.type != TileType.Desert ? tile.roll.toString() : ""}'));
    return react.g({}, children);
  }

  _handleMouseDown(react.SyntheticMouseEvent e) {
    print('TILE _handleMouseDown ${new Point(e.clientX, e.clientY)} ${tile.key}');
    if (e.shiftKey) actions.removeTile(tile.key);
    else actions.configureControlPalette(new TileControlPaletteConfig(tile, actions));
  }

  _handleTouchStart(react.SyntheticTouchEvent e) {
    print('TILE _handleTouchStart ${e.touches} ${tile.key}');
    if (e.shiftKey) actions.removeTile(tile.key);
    else actions.configureControlPalette(new TileControlPaletteConfig(tile, actions));
  }
}
