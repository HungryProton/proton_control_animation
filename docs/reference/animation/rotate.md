---
title: Rotate animation
layout: default
nav_order: 3
parent: Animations
---

# Rotate animation

Changes the control rotation over time.


## Enums

#### Rotation Type

+ **CURRENT_ROTATION**: The target control current rotation.
+ **ORIGINAL_ROTATION**: The target control rotation when the scene was first loaded.
+ **ABSOLUTE_ROTATION**: An absolute rotation.
+ **RELATIVE_ROTATION**: A relative rotation. This value will be added to the target current rotation.


## Properties

#### From

+ The control's rotation at the start of the animation.
+ See `RotationType` above.

#### From Absolute Rotation

+ This will override the control's `rotation` property when the animation starts.
+ Only applicable if `from == ABSOLUTE_ROTATION`

#### From Relative Rotation

+ Adds the value of `from_relative_rotation` to the control's current rotation when the animation starts.
+ Only applicable if `from == RELATIVE_ROTATION`

#### To

+ The control's rotation at the end of the animation
+ See `RotationType` above.

#### To Absolute Rotation

+ The control's `rotation` will be equal to `to_absolute_rotation` when the animation ends.
+ Only applicable if `to == ABSOLUTE_ROTATION`

#### To Relative Rotation

+ The control's `rotation` will be equal to `control.rotation + to_relative_rotation` when the animation ends.
+ Only applicable if `to == RELATIVE_ROTATION`


#### Rotation In Degrees

+ If true, the values `from_absolute_rotation`, `from_relative_rotation`, `to_absolute_rotation` and `to_relative_rotation` are expressed in degrees.
+ If false, they are expressed in radians.