-- created by bhristt (June 3rd 2021)
-- updated (October 12th 2022)
--!strict


--[[

Usage:

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

local SpringModule = require(script.Spring);
local Spring = SpringModule.new(mass, dampingConstant, springConstant, initialOffset, initialVelocity, externalForce);

** You can play around with the inputs and see how the spring module's offset will change using this graph! **

https://www.desmos.com/calculator/dqo46jlr7u

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Spring is an object with the following properties:

[Unchanging Properties]:

Spring.Mass                              --> the mass acting on the spring                      [number]
Spring.Damping                           --> the damping constant of the spring                 [number]
Spring.Constant                          --> the spring constant of the spring                  [number]
Spring.InitialOffset                     --> the initial offset of the spring                   [number]
Spring.InitialVelocity                   --> the initial velocity of the spring                 [number]
Spring.ExternalForce                     --> the external force acting on the spring            [number]

[Changing Properties]:

Spring.Offset                  --> the current offset of the spring                      [number]
Spring.Velocity                --> the current velocity of the spring                    [number]
Spring.Acceleration            --> the current acceleration of the spring                [number]

[Static Properties]:

Spring.StartTick                         --> the point in time at which the Spring was created         [number]
Spring.AdvancedObjectStringEnabled       --> changes how the spring prints                             [boolean]

**Spring properties are read only, trying to write the properties will not do anything and they will revert back to their respective values**

[Functions]:

Spring:Reset(): void                                --> resets the spring and creates a new DifEqFunctionTable
Spring:SetExternalForce(number Force): void         --> sets the external force of the spring to the given force
Spring:SetGoal(number Goal): void                   --> sets the external force of the sping such that the limit of the spring as t approaches infinity is the given number
Spring:AddOffset(number Offset): void               --> adds the given offset to the spring
Spring:AddVelocity(number Velocity): void           --> adds the given velocity to the spring
Spring:Print(): void                                --> prints the spring properties

[Internal Functions]:

Spring.F.Offset(number t): number                  --> returns the offset of the Spring at the given time t
Spring.F.Velocity(number t): number                --> returns the velocity of the spring at the given time t
Spring.F.Acceleration(number t): number            --> returns the acceleration of the spring at the given time t

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

** If you are looking for a more in depth version of the usage of this module, go to the devforum! The link is below **

https://devforum.roblox.com/t/physics-based-spring-module/1287742


]]


-- Services --





-- Modules --


local Eq = require(script.Eq);


-- Constants --


local SPRING_PROPERTIES = {
	OFFSET = "Offset",
	VELOCITY = "Velocity",
	ACCELERATION = "Acceleration",
	GOAL = "Goal",
};


local SPRING_PROPERTIES_FORMAT_STRING_BASIC = [[.
------------------------
SPRING PROPERTIES BASIC:
------------------------
[DELTA PROPERTIES]:
	--> [OFFSET]: %.3f
	--> [VELOCITY]: %.3f
	--> [ACCELERATION]: %.3f
]];


local SPRING_PROPERTIES_FORMAT_STRING_ADVANCED = [[.
---------------------------
SPRING PROPERTIES ADVANCED:
---------------------------
[BASE PROPERTIES]:
	--> MASS: %.3f
	--> DAMPING: %.3f
	--> SPRING CONSTANT: %.3f
	--> INITIAL OFFSET: %.3f
	--> INITIAL VELOCITY: %.3f
	--> EXTERNAL FORCE: %.3f
	--> START TICK: %f
[DELTA PROPERTIES]:
	--> [OFFSET]: %.3f
	--> [VELOCITY]: %.3f
	--> [ACCELERATION]: %.3f
]];


-- Class -- 


local Spring = {};
local SpringFunctions = {};


SpringFunctions.__index = function(self: SpringObject, index: any): any
	local INDEX_HANDLERS = {
		[SPRING_PROPERTIES.OFFSET] = function()
			local t: number = tick() - self.StartTick;
			local F: Eq.DifEqFunctionTable = self.F:: Eq.DifEqFunctionTable;
			local offset: number = F.Offset(t);
			return offset;
		end,
		[SPRING_PROPERTIES.VELOCITY] = function()
			local t: number = tick() - self.StartTick;
			local F: Eq.DifEqFunctionTable = self.F:: Eq.DifEqFunctionTable;
			local velocity: number = F.Velocity(t);
			return velocity;
		end,
		[SPRING_PROPERTIES.ACCELERATION] = function()
			local t: number = tick() - self.StartTick;
			local F: Eq.DifEqFunctionTable = self.F:: Eq.DifEqFunctionTable;
			local acceleration: number = F.Acceleration(t);
			return acceleration;
		end,
		[SPRING_PROPERTIES.GOAL] = function()
			local externalForce = self.ExternalForce;
			local constant = self.Constant;
			return externalForce / constant;
		end,
	}
	local rawValue = rawget(self, index);
	if rawValue ~= nil then
		return rawValue;
	end
	local indexHandler = INDEX_HANDLERS[index];
	if indexHandler ~= nil then
		return indexHandler();
	end
	return SpringFunctions[index];
end


SpringFunctions.__tostring = function(self: SpringObject): string
	local t: number = tick() - self.StartTick;
	local F: Eq.DifEqFunctionTable = self.F:: Eq.DifEqFunctionTable;
	local aose: boolean = self.AdvancedObjectStringEnabled;
	local formattedString: string;
	if aose == false then
		formattedString = string.format(
			SPRING_PROPERTIES_FORMAT_STRING_BASIC,
			F.Offset(t),
			F.Velocity(t),
			F.Acceleration(t)
		);
	elseif aose == true then
		formattedString = string.format(
			SPRING_PROPERTIES_FORMAT_STRING_ADVANCED,
			self.Mass,
			self.Damping,
			self.Constant,
			self.InitialOffset,
			self.InitialVelocity,
			self.ExternalForce,
			self.StartTick,
			F.Offset(t),
			F.Velocity(t),
			F.Acceleration(t)
		);
	end
	return formattedString;
end


-- Functions --


-- the spring object constructor
-- m: mass of object, a: damping constant, k: spring constant, y0: initial offset, v0: initial velocity, f: external force
function Spring.new(m: number, a: number, k: number, y0: number?, v0: number?, f: number?): SpringObject -- using a second order differential equation

	-- make sure values are valid
	assert(m > 0, "Mass for spring system cannot be less than or equal to 0");
	assert(k > 0, "Spring constant for spring system cannot be less than or equal to 0");

	-- double check to make sure y0, v0 and f are numbers and not nil values
	local y0 = y0 or 0;
	local v0 = v0 or 0;
	local f = f or 0;

	-- new spring object
	local _Spring: Eq.Spring = {

		-- set initial stuff
		Mass = m;
		Damping = a;
		Constant = k;
		InitialOffset = y0 - f/k;
		InitialVelocity = v0;
		ExternalForce = f;

		-- set boolean stuff
		AdvancedObjectStringEnabled = false;

		-- set cache stuff
		StartTick = 0;
	};

	-- adds the SpringFunctions to the spring object and returns the spring
	setmetatable(_Spring, SpringFunctions);

	-- starts the spring and returns the spring object
	(_Spring:: SpringObject):Reset(); -- _Spring and SpringObject are the same thing except SpringObject has a metatable, and lua can't see metatable functions :C
	return _Spring;
end


-- starts the spring
function SpringFunctions:Reset()
	local self: SpringObject = self;

	-- update the F of the spring
	self.F = Eq.F(self);

	-- set the start tick to the current tick and set enabled
	self.StartTick = tick();
end


-- sets the external force of the spring object to the given force
function SpringFunctions:SetExternalForce(force: number)
	local self: SpringObject = self;

	-- set properties
	self.ExternalForce = force;
	self.InitialOffset =  self.Offset - force / self.Constant;
	self.InitialVelocity =  self.Velocity;

	-- reset spring
	self:Reset();
end


-- sets the external force of the spring object such that
-- the spring object eventually reaches this number
function SpringFunctions:SetGoal(goal: number)
	local self: SpringObject = self;

	-- set properties
	self.ExternalForce = goal * self.Constant;
	self.InitialOffset = self.Offset - goal;
	self.InitialVelocity = self.Velocity;

	-- reset spring
	self:Reset();
end


-- adds the given offset to the spring object
function SpringFunctions:AddOffset(offset: number)
	local self: Eq.Spring & SpringObject = self;

	-- set properties and restart spring
	self.InitialOffset = self.Offset + offset;
	self.InitialVelocity = self.Velocity;
	self:Reset();
end


-- adds the given velocity to the spring object
function SpringFunctions:AddVelocity(velocity: number)
	local self: SpringObject = self;

	-- set properties and restart spring
	self.InitialOffset = self.Offset;
	self.InitialVelocity = self.Velocity + velocity;
	self:Reset();
end


-- prints the spring properties to the console
function SpringFunctions:Print()
	local self: SpringObject = self;

	-- create string of the object and print
	local springString = tostring(self);
	print(springString);
end


-- Return --


-- create a type for the spring object :0
type SpringObject = typeof(Spring.new(1, 0, 1)) & Eq.Spring;
return Spring;