---
title: Modulate animation
layout: default
nav_order: 3
parent: Animations
---

# Modulate animation

Changes the control's modulate (or self_modulate) color over time.

## Enums

#### ModulateType
+ **CURRENT_COLOR**: The control's current color.
+ **ORIGINAL_COLOR**: The control's color when the scene was loaded.
+ **NEW_COLOR**: A color specified from the animation resource.


## Properties

#### From

+ The control's color at the start of the animation.
+ See `ModulateType` above.

#### From Color

+ This color will replace the control's color when the animation starts.
+ Only applicable if `from == NEW_COLOR`

#### To

+ The control's color at the end of the animation.
+ See `ModulateType` above.

#### To Color

+ At the end of the animation, the control's color will have changed to `to_color`.
+ Only applicable if `to == NEW_COLOR`.

#### Self Modulate
+ If true, animate the control's `self_modulate` property.
+ If false, animation the control's `modulate` property.
