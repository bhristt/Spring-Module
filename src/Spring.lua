-- created by bhristt (June 3rd 2021)
-- updated (September 20th 2021)
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

Spring.Mass                    --> the mass acting on the spring
Spring.Damping                 --> the damping constant of the spring
Spring.Constant                --> the spring constant of the spring
Spring.InitialOffset           --> the initial offset of the spring
Spring.InitialVelocity         --> the initial velocity of the spring
Spring.ExternalForce           --> the external force acting on the spring

[Changing Properties]:

Spring.Offset                  --> the current offset of the spring
Spring.Velocity                --> the current velocity of the spring
Spring.Acceleration            --> the current acceleration of the spring
Spring.TimeElapsed             --> the time elapsed since the creation of the spring

**Spring properties are read only, trying to write the properties will not do anything and they will revert back to their respective values**

[Functions]:

Spring:Start()                                --> starts the spring if the spring has not already started
Spring:SetExternalForce(number Force)         --> sets the external force of the spring to the given force
Spring:Stop()                                 --> stops the spring and disconnects all connections tied to it

[Internal Functions]:

Spring.F.Offset(number t)                  --> returns the offset of the Spring at the given time t
Spring.F.Velocity(number t)                --> returns the velocity of the spring at the given time t
Spring.F.Acceleration(number t)            --> returns the acceleration of the spring at the given time t

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

** If you are looking for a more in depth version of the usage of this module, go to the devforum! The link is below **

https://devforum.roblox.com/t/physics-based-spring-module/1287742


]]


-- Services --


local RunService = game:GetService("RunService");


-- Modules --


local Eq = require(script.Eq);


-- Class -- 


local Spring = {};
local SpringFunctions = {};
SpringFunctions.__index = SpringFunctions;


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
		
		-- set changing stuff
		Offset = 0;
		Velocity = 0;
		Acceleration = 0;
		TimeElapsed = 0;
	};
	
	-- sets the important stuff of the spring
	_Spring.F = Eq.F(_Spring);
	
	-- adds the SpringFunctions to the spring object and returns the spring
	setmetatable(_Spring, SpringFunctions);
	
	-- starts the spring and returns the spring object
	_Spring:Start(); -- _Spring and SpringObject are the same thing except SpringObject has a metatable, and lua can't see metatable functions :C
	return _Spring;
end


-- starts the spring
function SpringFunctions:Start()
	local self: Eq.Spring = self;
	
	-- check to see if there is already a connection
	if self.Connection then
		return;
	end
	
	-- function used to update the spring using the DifEqFunctionTable
	local function Update(F: Eq.DifEqFunctionTable, dt: number)
		self.Offset = F.Offset(self.TimeElapsed);
		self.Velocity =  F.Velocity(self.TimeElapsed);
		self.Acceleration =  F.Acceleration(self.TimeElapsed);
		self.TimeElapsed += dt;
	end
	
	-- creates the connection to RunService for the spring
	self.Connection = RunService:IsServer() and RunService.Stepped:Connect(function(tt: number, dt: number)
		Update(self.F:: Eq.DifEqFunctionTable, dt);
	end) or RunService.RenderStepped:Connect(function(dt: number)
		Update(self.F:: Eq.DifEqFunctionTable, dt);
	end);
end


-- sets the external force of the spring object to the given force
function SpringFunctions:SetExternalForce(Force: number)
	local self: Eq.Spring = self;
	
	-- set properties
	self.ExternalForce = Force;
	self.InitialOffset =  self.Offset - Force / self.Constant;
	self.InitialVelocity =  self.Velocity
	self.F = Eq.F(self);
	self.TimeElapsed = 0;
end


-- stops the spring and its connection to the RunService
function SpringFunctions:Stop()
	local self: Eq.Spring = self;
	
	-- check if a connection exists
	if not self.Connection then
		return;
	end
	
	(self.Connection:: RBXScriptConnection):Disconnect();
	self.Connection = nil;
end


-- Return --


-- create a type for the spring object :0
type SpringObject = typeof(Spring.new(1, 0, 1));
return Spring;