pragma Singleton
import Quickshell

Singleton {
    id: root

    property real accum: 0

    // Accumulate small high-res wheel deltas and return discrete steps.
    // For standard mice: angleDelta.y is typically ±120, returns ±1 immediately.
    // For high-res mice (e.g. MX Anywhere): angleDelta.y is small (15-20),
    // accumulates until reaching ±120, then returns the step count.
    function getSteps(angleDeltaY) {
        root.accum = root.accum + angleDeltaY
        if (Math.abs(root.accum) >= 120) {
            const steps = Math.trunc(root.accum / 120)
            root.accum = root.accum - steps * 120
            return steps
        }
        return 0
    }
}