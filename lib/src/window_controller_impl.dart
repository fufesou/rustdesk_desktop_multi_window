import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'channels.dart';
import 'widgets/sub_drag_to_resize_area.dart';
import 'window_controller.dart';

double getDevicePixelRatio() {
  // Subsequent version, remove this deprecated member.
  // ignore: deprecated_member_use
  return window.devicePixelRatio;
}

class WindowControllerMainImpl extends WindowController {
  final MethodChannel _channel = miltiWindowChannel;

  // the id of this window
  final int _id;

  WindowControllerMainImpl(this._id);

  @override
  int get windowId => _id;

  @override
  Future<void> close() {
    return _channel.invokeMethod('close', _id);
  }

  @override
  Future<void> hide() {
    return _channel.invokeMethod('hide', _id);
  }

  @override
  Future<bool> isHidden() async {
    return (await _channel.invokeMethod<bool>('isHidden', _id)) ?? false;
  }

  @override
  Future<void> show() {
    return _channel.invokeMethod('show', _id);
  }

  @override
  Future<void> center() {
    return _channel.invokeMethod('center', _id);
  }

  @override
  Future<void> setFrame(Rect frame) {
    return _channel.invokeMethod('setFrame', <String, dynamic>{
      'windowId': _id,
      'left': frame.left,
      'top': frame.top,
      'width': frame.width,
      'height': frame.height,
    });
  }

  @override
  Future<Rect> getFrame() async {
    final Map<String, dynamic> arguments = {
      'windowId': _id,
    };
    final Map<dynamic, dynamic> resultData = await _channel.invokeMethod(
      'getFrame',
      arguments,
    );
    return Rect.fromLTWH(
      resultData['x'],
      resultData['y'],
      resultData['width'],
      resultData['height'],
    );
  }

  /// Returns `Rect` - The bounds of the window as Object.
  Future<Rect> getBounds() async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': getDevicePixelRatio(),
      'windowId': _id,
    };
    final Map<dynamic, dynamic> resultData = await _channel.invokeMethod(
      'getBounds',
      arguments,
    );

    return Rect.fromLTWH(
      resultData['x'],
      resultData['y'],
      resultData['width'],
      resultData['height'],
    );
  }

  /// Resizes and moves the window to the supplied bounds.
  Future<void> setBounds(
    Rect? bounds, {
    Offset? position,
    Size? size,
    bool animate = false,
  }) async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': getDevicePixelRatio(),
      'x': bounds?.topLeft.dx ?? position?.dx,
      'y': bounds?.topLeft.dy ?? position?.dy,
      'width': bounds?.size.width ?? size?.width,
      'height': bounds?.size.height ?? size?.height,
      'animate': animate,
    }..removeWhere((key, value) => value == null);
    await _channel.invokeMethod('setBounds', arguments);
  }

  /// Returns `Size` - Contains the window's width and height.
  Future<Size> getSize() async {
    Rect bounds = await getBounds();
    return bounds.size;
  }

  /// Resizes the window to `width` and `height`.
  Future<void> setSize(Size size, {bool animate = false}) async {
    await setBounds(
      null,
      size: size,
      animate: animate,
    );
  }

  @override
  Future<void> setTitle(String title) {
    return _channel.invokeMethod('setTitle', <String, dynamic>{
      'windowId': _id,
      'title': title,
    });
  }

  @override
  Future<void> setFrameAutosaveName(String name) {
    return _channel.invokeMethod('setFrameAutosaveName', <String, dynamic>{
      'windowId': _id,
      'name': name,
    });
  }

  @override
  Future<void> focus() {
    return _channel.invokeMethod('focus', _id);
  }

  @override
  Future<void> setFullscreen(bool fullscreen) {
    await _channel.invokeMethod('setFullscreen',
        <String, dynamic>{'windowId': _id, 'fullscreen': fullscreen});
    // (Windows) Force refresh the app so it 's back to the correct size
    // (see GitHub issue #311) https://github.com/leanflutter/window_manager/issues/311
    if (Platform.isWindows) {
      final size = await getSize();
      setSize(size + const Offset(1, 1));
      setSize(size);
    }
  }

  @override
  Future<void> startDragging() {
    return _channel.invokeMethod('startDragging', _id);
  }

  /// Sets whether the window can be moved by user.
  ///
  /// @platforms macos
  /// @override
  Future<void> setMovable(bool isMovable) async {
    return _channel.invokeMethod('setMovable', <String, dynamic>{'windowId': _id, 'isMovable': isMovable});
  }

  @override
  Future<bool> isMaximized() async {
    return (await _channel.invokeMethod<bool>('isMaximized', _id)) ?? false;
  }

  @override
  Future<bool> isMinimized() async {
    return (await _channel.invokeMethod<bool>('isMinimized', _id)) ?? false;
  }

  @override
  Future<void> maximize() {
    return _channel.invokeMethod('maximize', _id);
  }

  @override
  Future<void> minimize() {
    return _channel.invokeMethod('minimize', _id);
  }

  @override
  Future<void> unmaximize() {
    return _channel.invokeMethod('unmaximize', _id);
  }

  @override
  Future<void> showTitleBar(bool show) {
    return _channel.invokeMethod(
        'showTitleBar', <String, dynamic>{'windowId': _id, 'show': show});
  }

  @override
  Future<void> startResizing(SubWindowResizeEdge subWindowResizeEdge) {
    return _channel.invokeMethod<bool>(
      'startResizing',
      {
        "windowId": _id,
        "resizeEdge": describeEnum(subWindowResizeEdge),
        "top": subWindowResizeEdge == SubWindowResizeEdge.top ||
            subWindowResizeEdge == SubWindowResizeEdge.topLeft ||
            subWindowResizeEdge == SubWindowResizeEdge.topRight,
        "bottom": subWindowResizeEdge == SubWindowResizeEdge.bottom ||
            subWindowResizeEdge == SubWindowResizeEdge.bottomLeft ||
            subWindowResizeEdge == SubWindowResizeEdge.bottomRight,
        "right": subWindowResizeEdge == SubWindowResizeEdge.right ||
            subWindowResizeEdge == SubWindowResizeEdge.topRight ||
            subWindowResizeEdge == SubWindowResizeEdge.bottomRight,
        "left": subWindowResizeEdge == SubWindowResizeEdge.left ||
            subWindowResizeEdge == SubWindowResizeEdge.topLeft ||
            subWindowResizeEdge == SubWindowResizeEdge.bottomLeft,
      },
    );
  }

  @override
  Future<bool> isPreventClose() async {
    return await _channel.invokeMethod<bool>('isPreventClose', _id) ?? false;
  }

  @override
  Future<void> setPreventClose(bool setPreventClose) async {
    final Map<String, dynamic> arguments = {
      'setPreventClose': setPreventClose,
      'windowId': _id
    };
    await _channel.invokeMethod('setPreventClose', arguments);
  }

  @override
  Future<int> getXID() async {
    final Map<String, dynamic> arguments = {'windowId': _id};
    return await _channel.invokeMethod<int>('getXID', arguments) ?? -1;
  }

  @override
  Future<bool> isFullScreen() async {
    final Map<String, dynamic> arguments = {'windowId': _id};
    return await _channel.invokeMethod<bool>('isFullScreen', arguments) ??
        false;
  }
}
