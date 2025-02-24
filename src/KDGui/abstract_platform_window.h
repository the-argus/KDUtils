/*
  This file is part of KDUtils.

  SPDX-FileCopyrightText: 2018-2023 Klarälvdalens Datakonsult AB, a KDAB Group company <info@kdab.com>
  Author: Paul Lemire <paul.lemire@kdab.com>

  SPDX-License-Identifier: MIT

  Contact KDAB at <info@kdab.com> for commercial licensing options.
*/

#pragma once

#include <KDFoundation/kdfoundation_global.h>
#include <KDGui/kdgui_keys.h>

#include <string>

namespace KDGui {

class Window;

class AbstractPlatformWindow
{
public:
    explicit AbstractPlatformWindow(Window *window);
    virtual ~AbstractPlatformWindow() { }

    AbstractPlatformWindow(AbstractPlatformWindow const &other) = delete;
    AbstractPlatformWindow &operator=(AbstractPlatformWindow const &other) = delete;

    AbstractPlatformWindow(AbstractPlatformWindow &&other) noexcept = default;
    AbstractPlatformWindow &operator=(AbstractPlatformWindow &&other) noexcept = default;

    Window *window() { return m_window; }

    virtual bool create() = 0;
    virtual bool destroy() = 0;
    virtual bool isCreated() = 0;

    virtual void map() = 0;
    virtual void unmap() = 0;

    virtual void disableCursor() = 0;
    virtual void enableCursor() = 0;

    virtual void enableRawMouseInput() = 0;
    virtual void disableRawMouseInput() = 0;

    virtual void setTitle(const std::string &title) = 0;

    virtual void setSize(uint32_t width, uint32_t height) = 0;
    virtual void handleResize(uint32_t width, uint32_t height) = 0;

    // Buttons:
    //  1 = Left, 2 = Middle, 3 = Right,
    //  4 = Mouse Wheel Up, 5 = Mouse Wheel Down,
    //  6 = Horiz Mouse Wheel Up, 7 = Horiz Mouse Wheel Down,
    //  8 = Navigate Back, 9 = Navigate Forward
    // TODO: Wrap these up in an enum and map from the platform specific codes to our codes
    virtual void handleMousePress(
            uint32_t timestamp, uint8_t button,
            int16_t xPos, int16_t yPos) = 0;

    virtual void handleMouseRelease(
            uint32_t timestamp, uint8_t button,
            int16_t xPos, int16_t yPos) = 0;

    virtual void handleMouseMove(
            uint32_t timestamp, uint8_t button,
            int64_t xPos, int64_t yPos) = 0;

    virtual void handleMouseWheel(uint32_t timestamp, int32_t xDelta, int32_t yDelta) = 0;

    virtual void handleKeyPress(uint32_t timestamp, uint8_t nativeKeyCode, Key key, KeyboardModifiers modifiers) = 0;
    virtual void handleKeyRelease(uint32_t timestamp, uint8_t nativeKeyCode, Key key, KeyboardModifiers modifiers) = 0;
    virtual void handleTextInput(const std::string &str) = 0;

protected:
    Window *m_window;
};

} // namespace KDGui
