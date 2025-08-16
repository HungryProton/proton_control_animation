---
title: Animations
layout: default
nav_order: 2
parent: Reference
---

# Animation resources

Animation resources are assigned to a `ProtonControlAnimation` node and defines how the animation looks like.
Every animation shares common properties and relies on Tweens internally.

## Properties

#### Easing

- Controls where the animation is interpolated.
- See the [Godot documentation](https://docs.godotengine.org/en/stable/classes/class_tween.html#enum-tween-easetype) on tweens for more information.

#### Transition

- Controls the interpolation type.
- See the [Godot documentation](https://docs.godotengine.org/en/stable/classes/class_tween.html#enum-tween-transitiontype) on tweens for more information.

#### Default duration

- How long the animation lasts.
- Overriden by the AnimationControl duration.
