-- created by bhristt (June 3rd 2021)
-- updated (November 9th 2023)


--[[

Usage:

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

local SpringModule = require(script.Spring);
local Spring = SpringModule.new(mass, dampingConstant, springConstant, initialOffset, initialVelocity, goal);
local Spring = SpringModule.fromFrequency(mass, dampingConstant, frequency, initialOffset, intialVelocity, goal);

** You can play around with the inputs and see how the spring module's offset will change using this graph! **

https://www.desmos.com/calculator/1lzjxyfjum

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Spring is an object with the following properties:

[Unchanging Properties]:

Spring.Mass                              --> the mass acting on the spring                      [number]
Spring.Damping                           --> the damping constant of the spring                 [number]
Spring.Constant                          --> the spring constant of the spring                  [number]
Spring.InitialOffset                     --> the initial offset of the spring                   [number]
Spring.InitialVelocity                   --> the initial velocity of the spring                 [number]
Spring.ExternalForce                     --> the external force acting on the spring            [number]
Spring.Goal                              --> the offset the spring is aiming to get to          [number]
Spring.Frequency                         --> the frequency of the system                        [number]

[Changing Properties]:

Spring.Offset                  --> the current offset of the spring                      [number]
Spring.Velocity                --> the current velocity of the spring                    [number]
Spring.Acceleration            --> the current acceleration of the spring                [number]

[Static Properties]:

Spring.StartTick                         --> the point in time at which the Spring was created         [number]
Spring.AdvancedObjectStringEnabled       --> changes how the spring prints                             [boolean]

**Spring properties are read only, trying to write the properties will not do anything and they will revert back to their respective values**

[Functions]:

Spring:Reset(): void                                                       --> resets the spring and creates a new DifEqFunctionTable
Spring:SetExternalForce(number Force): void                                --> sets the external force of the spring to the given force
Spring:SetGoal(number Goal): void                                          --> sets the external force of the spring such that the limit of the spring as t approaches infinity is the given number
Spring:SetFrequency(number Frequency): void                                --> sets the spring constant of the spring such that the frequency of the system is the given frequency
Spring:SnapToCriticalDamping(): void                                       --> snaps the spring to the critical damping state by changing the damping
Spring:SetOffset(number Offset, boolean? ZeroVelocity): void               --> sets the spring offset to the given offset; if zeroVelocity = true, spring velocity is set to 0; zeroVelocity = false by default
Spring:AddOffset(number Offset): void                                      --> adds the given offset to the spring
Spring:SetVelocity(number Velocity): void                                  --> sets the velocity of the spring to the given velocity
Spring:AddVelocity(number Velocity): void                                  --> adds the given velocity to the spring
Spring:Print(): void                                                       --> prints the spring properties

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


local Eq = require(script:WaitForChild("Eq"));


-- Declarations --


local sqrt = math.sqrt


-- Constants --


local PI = math.pi

local SPRING_PROPERTIES = {
	OFFSET = "Offset",
	VELOCITY = "Velocity",
	ACCELERATION = "Acceleration",
	GOAL = "Goal",
	FREQUENCY = "Frequency",
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
	--> STIFFNESS: %.3f
	--> GOAL: %.3f
	--> FREQUENCY: %.3f
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
		[SPRING_PROPERTIES.FREQUENCY] = function()
			local damping = self.Damping;
			local stiffness = self.Constant;
			local mass = self.Mass;
			return sqrt(-damping*damping + 4*stiffness/mass)/(2*PI);
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
			self.Goal,
			self.Frequency,
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
function Spring.new(mass: number, damping: number, stiffness: number, y0: number?, v0: number?, goal: number?): SpringObject -- using a second order differential equation

	-- make sure values are valid
	assert(mass > 0, "Mass for spring system cannot be less than or equal to 0");
	assert(stiffness > 0, "Spring constant for spring system cannot be less than or equal to 0");

	-- double check to make sure y0, v0 and f are numbers and not nil values
	y0 = y0 or 0;
	v0 = v0 or 0;
	goal = goal or 0;

	local extf = goal:: number*stiffness;

	-- new spring object
	local _Spring: Eq.Spring = {

		-- set initial stuff
		Mass = mass;
		Damping = damping;
		Constant = stiffness;
		InitialOffset = y0:: number - goal:: number;
		InitialVelocity = v0:: number;
		ExternalForce = extf;

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

-- the spring object constructor using frequency instead of spring constant
function Spring.fromFrequency(mass: number, damping: number, frequency: number, y0: number?, v0: number, goal: number?): SpringObject

	-- make sure values are valid
	assert(mass > 0, "Mass for spring system cannot be less than or equal to 0");
	assert(frequency > 0, "Spring frequency for spring system cannot be less than or equal to 0");

	local stiffness = 0.25*mass*(4*PI*PI*frequency*frequency + damping*damping);

	y0 = y0 or 0;
	v0 = v0 or 0;
	goal = goal or 0;

	local extf = goal:: number*stiffness;

	local _Spring: Eq.Spring = {

		-- set initial stuff
		Mass = mass;
		Damping = damping;
		Constant = stiffness;
		InitialOffset = y0:: number - goal:: number;
		InitialVelocity = v0:: number;
		ExternalForce = extf;

		--set boolean stuff
		AdvancedObjectStringEnabled = false;

		-- set cache stuff
		StartTick = 0;
	}

	setmetatable(_Spring, SpringFunctions);

	(Spring:: SpringObject):Reset();
	return _Spring;
end


-- starts the spring
function SpringFunctions:Reset(): ()
	-- update the F of the spring
	self.F = Eq.F(self);

	-- set the start tick to the current tick and set enabled
	self.StartTick = tick();
end


-- sets the external force of the spring object to the given force
function SpringFunctions:SetExternalForce(force: number): ()
	-- set properties
	self.ExternalForce = force;
	self.InitialOffset =  self.Offset - force / self.Constant;
	self.InitialVelocity =  self.Velocity;

	-- reset spring
	self:Reset();
end


-- sets the external force of the spring object such that
-- the spring object eventually reaches this number
function SpringFunctions:SetGoal(goal: number): ()
	-- set properties
	self.ExternalForce = goal * self.Constant;
	self.InitialOffset = self.Offset - goal;
	self.InitialVelocity = self.Velocity;

	-- reset spring
	self:Reset();
end


-- sets the stiffness (spring constant) of the spring object
-- such that the frequency of the spring is equal to the
-- given frequency
function SpringFunctions:SetFrequency(frequency: number): ()
	-- set properties
	self.Constant = 0.25*self.Mass*(4*PI*PI*frequency*frequency + self.Damping*self.Damping);
	self.InitialOffset = self.Offset;
	self.InitialVelocity = self.Velocity;

	-- reset spring
	self:Reset();
end


-- sets the damping of the spring object such that the damping
-- is enough to trigger critical damping; the least amount of damping
-- a system can have before it becomes an oscillating system
function SpringFunctions:SnapToCriticalDamping(): ()
	-- set properties
	self.Damping = 2*sqrt(self.Constant/self.Mass)
	self.InitialOffset = self.Offset;
	self.InitialVelocity = self.Velocity;

	-- reset spring
	self:Reset();
end



-- sets the offset of the spring object to the given offset
function SpringFunctions:SetOffset(offset: number, zeroVelocity: boolean?): ()
	-- set properties and restart spring
	self.InitialOffset = offset - self.Goal;
	self.InitialVelocity = zeroVelocity and 0 or self.Velocity;

	-- reset spring
	self:Reset();
end


-- adds the given offset to the spring object
function SpringFunctions:AddOffset(offset: number): ()
	-- set properties and restart spring
	self.InitialOffset = self.Offset + offset;
	self.InitialVelocity = self.Velocity;

	-- reset spring
	self:Reset();
end


-- sets the velocity of the spring object to the given velocity
function SpringFunctions:SetVelocity(velocity: number): ()
	-- set properties and restart spring
	self.InitialOffset = self.Offset
	self.InitialVelocity = velocity;

	-- reset spring
	self:Reset();
end


-- adds the given velocity to the spring object
function SpringFunctions:AddVelocity(velocity: number): ()
	-- set properties and restart spring
	self.InitialOffset = self.Offset;
	self.InitialVelocity = self.Velocity + velocity;
	self:Reset();
end


-- prints the spring properties to the console
function SpringFunctions:Print(): ()
	-- create string of the object and print
	local springString = tostring(self);
	print(springString);
end


-- Return --


-- create a type for the spring object :0
type SpringObject = typeof(Spring.new(1, 0, 1)) & Eq.Spring;
return Spring;