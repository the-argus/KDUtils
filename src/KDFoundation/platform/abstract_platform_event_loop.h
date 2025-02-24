/*
  This file is part of KDUtils.

  SPDX-FileCopyrightText: 2018-2023 Klarälvdalens Datakonsult AB, a KDAB Group company <info@kdab.com>
  Author: Paul Lemire <paul.lemire@kdab.com>

  SPDX-License-Identifier: MIT

  Contact KDAB at <info@kdab.com> for commercial licensing options.
*/

#pragma once

#include <memory>

#include <KDFoundation/kdfoundation_global.h>
#include <KDFoundation/platform/abstract_platform_timer.h>

namespace KDFoundation {

class Postman;
class FileDescriptorNotifier;
class AbstractPlatformTimer;
class Timer;

class KDFOUNDATION_API AbstractPlatformEventLoop
{
public:
    virtual ~AbstractPlatformEventLoop() { }

    void setPostman(Postman *postman) { m_postman = postman; }
    Postman *postman() { return m_postman; }

    // timeout in msecs
    // -1 means wait forever
    // 0 means do not wait (i.e. poll)
    // +ve number, wait for up to timeout msecs
    virtual void waitForEvents(int timeout) = 0;

    // Kick the event loop out of waiting
    virtual void wakeUp() = 0;

    virtual bool registerNotifier(FileDescriptorNotifier *notifier) = 0;
    virtual bool unregisterNotifier(FileDescriptorNotifier *notifier) = 0;

    std::unique_ptr<AbstractPlatformTimer> createPlatformTimer(Timer *timer)
    {
        return createPlatformTimerImpl(timer);
    }

protected:
    virtual std::unique_ptr<AbstractPlatformTimer> createPlatformTimerImpl(Timer *timer) = 0;

    Postman *m_postman{ nullptr };
};

} // namespace KDFoundation
