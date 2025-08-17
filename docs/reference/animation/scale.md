---
title: Scale animation
layout: default
nav_order: 3
parent: Animations
---

# Scale animation

Changes the control size over time.


## Enums

#### Scale Type

+ **CURRENT_SCALE**: The target control current scale.
+ **ORIGINAL_SCALE**: The target control scale when the scene was first loaded.
+ **ABSOLUTE_SCALE**: An absolute scale.
+ **RELATIVE_SCALE**: A relative scale. This value will be multiplied by the target current scale.


## Properties

#### From

+ The control's scale at the start of the animation.
+ See `ScaleType` above.

#### From Absolute Scale

+ This will override the control's `scale` property when the animation starts.
+ Only applicable if `from == ABSOLUTE_SCALE`

#### From Relative Scale

+ The control's current scale will is multiplied by `from_relative_scale` when the animation starts.
+ Only applicable if `from == RELATIVE_SCALE`
+ **Example**: If this is set to `2.0`, the animation will set the control scale to 2 times the current scale when starting the animation.

#### To

+ The control's scale at the end of the animation.
+ See `ScaleType` above.

#### To Absolute Scale

+ At the end of the animation, the control's scale will be equal to `to_absolute_scale`.
+ Only applicable if `to == ABSOLUTE_SCALE`.

#### To Relative Scale

+ At the end of the animation, the control's `scale` will be equal to `control.scale * to_relative_scale`.
+ Only applicable if `to == RELATIVE_SCALE`
