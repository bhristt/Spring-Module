# Spring Module

The **Spring Module** is a module that allows you to create a realistic spring object that acts in one direction. This module creates a general solution to a second order differential equation given some inputs. It’s simple to use and is very useful in creating recoil systems, realistic spring systems, and anything else you can imagine a spring is useful for. This spring module is able to accurately replicate real springs.

# API

## Constructor

To create a new SpringObject, you can use the constructor

> [SpringObject] **Spring.new([number] mass, [number] damping, [number] springConstant, [number?] initOffset, [number?] initVel, [number?] externalForce)**

Constructor use looks like:

```lua
local Spring = require(script:WaitForChild("Spring"))
--// only the first 3 parameters are required to make a
local SpringObject = Spring.new(1, 0, 1)
```
Desmos Spring Graph: https://www.desmos.com/calculator/dqo46jlr7u

## Properties

The Spring Object contains the following properties:

> [number] **SpringObject.Mass**

The mass of the Spring Object

> [number] **SpringObject.Damping**

The damping constant of the Spring Object

> [number] **SpringObject.Constant**

The spring constant of the Spring Object (not to be confused with the damping constant)

> [number] **SpringObject.InitialOffset**

The initial offset of the Spring Object

> [number] **SpringObject.InitialVelocity**

The initial velocity of the Spring Object

> [number] **SpringObject.ExternalForce**

The external force acting on the Spring Object

> [number] **SpringObject.Goal**

The offset the spring is aiming to get to as time approaches infinity

> [number] **SpringObject.Offset**

The current offset of the Spring Object (this constantly changes)

> [number] **SpringObject.Velocity**

The current velocity of the Spring Object (this constantly changes)

> [number] **SpringObject.Acceleration**

The current acceleration of the Spring Object (this constantly changes)

> [number] **SpringObject.StartTick**

The point in time at which the Spring Object was created

> [boolean] **SpringObject.AdvancedObjectStringEnabled**

Whether to use the basic string or advanced string for the Spring Object when **tostring()** is called on the Spring Object

## Functions

The Spring Object contains the following functions:

---


> [void] **SpringObject.Reset()**

Resets the Spring and creates a new **DifEqFunctionTable** for the Spring Object

> [void] **SpringObject:SetExternalForce([number] force)**

Sets the external force of the Spring Object to the given force

> [void] **SpringObject:SetGoal([number] goal)**

Sets the external force of the Spring Object such that the the limit of the spring as t approaches infinity is equal to the given number (same as `SpringObject:SetExternalForce(goal*SpringObject.Constant)`)

> [void] **SpringObject:AddOffset([number] offset)**

Adds the given offset to the Spring Object

> [void] **SpringObject:AddVelocity([number] velocity)**

Adds the given velocity to the Spring Object

> [void] **SpringObject:Print()**

Prints the Spring Object's properties (different print based on **AdvancedObjectStringEnabled**)

## Internal functions

There are some cases where using the internal functions of the SpringObject is necessary. In these cases, it's necessary to use **SpringObject.F**

> [table] **SpringObject.F**

**SpringObject.F** is a table that consists of 3 functions:

> [number] **SpringObject.F.Offset([number] t)**

Returns an offset based on the given t value

> [number] **SpringObject.F.Velocity([number] t)**

Returns a velocity based on the given t value

> [number] **Spring.F.Acceleration([number] t)**

Returns an acceleration based on the given t value