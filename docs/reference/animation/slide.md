---
title: Slide animation
layout: default
nav_order: 3
parent: Animations
---

# Slide animation

Moves the control over time from a point A to a point B.


## Enums

#### PositionType

+ **CURRENT_POSITION**: The target control current position.
+ **ORIGINAL_POSITION**: The target control position when the scene was loaded or last resized / resorted.
+ **GLOBAL_POSITION**: An absolute position.
+ **LOCAL_OFFSET**: A relative position. This value will be added the the target current position.


## Properties

#### From

+ Defines where the animation starts.
+ See `PositionType` above.

#### From Global Position

+ This overrides the control's global position when the animation starts
+ Only applicable if `from == GLOBAL_POSITION`

#### From Local Offset

+ `from_local_offset` is added to the control's current position when the animation starts.
+ Only applicable if `from == LOCAL_OFFSET`
+ **Example**: If this is set to `Vector2(100, 0)`, the animation will place the control 100 pixels to the right when starting the animation.

#### To

+ Defines where the animation ends.
+ See `PositionType` above.

#### To Global Position

+ The global position where the animation ends.
+ At the end of the animation, the control global position will be equal to `to_global_position`.
+ Only applicable if `to == GLOBAL_POSITION`

#### To Local Offset

+ At the end of the animation, the control's position will equal `control.position + to_local_offset`.
+ Only applicable if `to == LOCAL_OFFSET`
+ **Example**: If this is set to `Vector2(100, 0)`, the control will be progressively moves 100 pixels to the right over the course of the animation.
