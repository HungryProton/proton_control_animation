---
title: ProtonControlAnimation
layout: default
nav_order: 2
parent: Reference
---

# ProtonControlAnimation

Controls which animation should be played on a given control and when.
This is the main node you will interact with.

## Properties

#### Target
+ The control node that will be animated.
+ This can be any control, placed anywhere on the tree.
+ Default to the parent node if empty.

#### Animation
+ The `ProtonControlAnimationResource` that defines how the control is animated.
+ See [this documentation page](/proton_control_animation/reference/animations.html) for more information.

#### Duration
+ How long the animation will last in seconds.
+ This takes priority over the default duration from the animation resource.
+ Set this to a negative value to use the default duration.

#### Delay
+ Wait this amount of time (in seconds) before starting the animation.

#### Loop Type
+ None: The animation doesn't loop. Calling `start()` will play it once.
+ Linear: The animation plays to the end, then plays back again from the start.
+ PingPong: The animation plays to the end, then plays backward to the beginng. The round trip is counted as one loop.

#### Loop Count
+ When calling `start()`, the animation with play this many times before emitting the `animation_ended` signal.

#### Accumulate Start Events
+ By default, calling start() will do nothing if the animation is already playing.
+ If `accumulate_start_events` is enabled, and `start()` is called during playback, the animation will play again once it reaches the end.

#### Trigger Source
+ A helper variable for quickly connecting common signals to the `start()` method.
+ This can be a `Control` or a `ProtonControlAnimation`. The available triggers in the inspector will update accordingly.

#### Common Triggers
These depends on the `trigger_source`
If any of these properties are enabled, the animation will play when the corresponding signal is emitted.
It's exactly the same as going to the signals panel and connecting the relevant signals to the `start()` method.

+ **on_show:** Plays the animation when the source becomes visible.
+ **on_hide:** Plays the animation when the source is hidden.
+ **on_hover_start:** Plays the animation when the mouse enters the Control.
+ **on_hover_stop:** Plays the animation when the mouse exits the Control.
+ **on_focus_entered:** Plays the animation when the control aquires the focus.
+ **on_focus_exited:** Plays the animation when the control releases the focus.
+ **on_pressed:** Plays the animation when the Button is pressed.
	- Only applicable if `trigger_source` is a button.
+ **on_animation_start:** Plays the animation when the source animation starts.
	- Only applicable if `trigger_source` is a `ProtonControlAnimation`.
+ **on_animation_end:** Plays the animation when the source animation ends.
	- Only applicable if `trigger_source` is a `ProtonControlAnimation`.

+ **Custom Signal:** Starts the animation when this signal is emitted from the trigger source.
	- Foolproof way of connecting a signal to the start() method, as this technique handles unbinding the arguments automatically if any.

## Method

+ **start()**: Call this method to play the animation.
