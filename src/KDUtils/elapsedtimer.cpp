/*
  This file is part of KDUtils.

  SPDX-FileCopyrightText: 2021-2023 Klarälvdalens Datakonsult AB, a KDAB Group company <info@kdab.com>
  Author: Paul Lemire <paul.lemire@kdab.com>

  SPDX-License-Identifier: MIT

  Contact KDAB at <info@kdab.com> for commercial licensing options.
*/

#include "elapsedtimer.h"

namespace KDUtils {

ElapsedTimer::ElapsedTimer() = default;

ElapsedTimer::NsecDuration ElapsedTimer::elapsed() const
{
    const TimePoint now = Clock::now();
    return now - m_startTimePoint;
}

int64_t ElapsedTimer::nsecElapsed() const
{
    return elapsed().count();
}

int64_t ElapsedTimer::msecElapsed() const
{
    return std::chrono::duration_cast<MsecDuration>(elapsed()).count();
}

ElapsedTimer::NsecDuration ElapsedTimer::restart()
{
    const NsecDuration lastElapsed = elapsed();
    start();
    return lastElapsed;
}

void ElapsedTimer::start()
{
    m_startTimePoint = Clock::now();
}

} // namespace KDUtils
