// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class BoardStore extends w_flux.Store {
  w_module.DispatchKey _dispatch;
  GameActions _actions;
  GameEvents _events;

  Board _board;
  Board get board => _board;

  Rectangle _viewport = new Rectangle(0, 0, 0, 0);
  Rectangle get viewport => _viewport;

  BoardStore(this._actions, this._events, this._dispatch) {
    _actions
      ..addTile.listen(_handleAddTile)
      ..removeTile.listen(_handleRemoveTile)
      ..addPlayer.listen(_handleAddPlayer)
      ..removePlayer.listen(_handleRemovePlayer)
      ..startNewGame.listen(_startNewGame);

      String mapParam = Uri.base.queryParameters['map'];
      List<String> tileStrings = _splitMapParam(mapParam);
      if (tileStrings.length > 0) _startNewGameFromURI(tileStrings);
      else _startNewGame();
  }

  _startNewGame([_]) {
    _board = new Board.standard();
    _update();
  }

  _startNewGameFromURI(List<String> tileStrings) {
    List<int> keys = new List<int>();
    List<TileType> types = new List<TileType>();
    List<int> rolls = new List<int>();
    tileStrings.forEach((tileString) {
      if (tileString.length == 7) {
        keys.add(int.parse(tileString.substring(0, 4)));
        types.add(tileTypeFromString(tileString.substring(6)));
        rolls.add(int.parse(tileString.substring(4, 6)));
      }
    });
    _board = new Board(keys, types, rolls);
    _update();
  }

  _update() {
    double maxManDist = 0.0;
    board.tiles.forEach((_, tile) {
      double posX = tile.coordinate.point.x.toDouble().abs();
      double posY = tile.coordinate.point.y.toDouble().abs();
      if (posX > maxManDist) maxManDist = posX;
      if (posY > maxManDist) maxManDist = posY;
    });
    _viewport = new Rectangle(
      -1 * maxManDist - (SPACING_X * 3),
      -1 * maxManDist - (SPACING_Y * 3),
      2 * maxManDist + (SPACING_X * 6),
      2 * maxManDist + (SPACING_Y * 6));

    _pushBoardToURI();
    print('BoardStore._update()');
    trigger();
  }

  _pushBoardToURI() {
    List<String> mapParam = new List<String>();
    board.tiles.values.forEach((tile) {
      mapParam.add('${tile.key.toString().padLeft(4, "0")}${tile.roll.toString().padLeft(2, "0")}${stringFromTileType(tile.type)}');
    });
    Uri current = Uri.base;
    Map<String, String> params = new Map<String, String>.from(current.queryParameters);
    params['map'] = mapParam.join('');
    current = current.replace(queryParameters: params);
    window.history.pushState('', '', current.toString());
  }

  List<String> _splitMapParam(String mapParam) {
    List<String> tileStrings = new List<String>();
    if (mapParam != null) {
      for (int i = 0; i + 7 <= mapParam.length; i += 7) {
        tileStrings.add(mapParam.substring(i, i + 7));
      }
    }
    return tileStrings;
  }

  // Handle Player Actions

  _handleAddPlayer(Player player) {
    if (board.addPlayer(player)) trigger();
  }

  _handleRemovePlayer(Player player) {
    if (board.removePlayer(player)) trigger();
  }

  // Handle Tile Actions

  _handleAddTile(int key) {
    if (board.addTile(key)) _update();
  }

  _handleRemoveTile(int key) {
    if (board.removeTile(key)) _update();
  }
}
