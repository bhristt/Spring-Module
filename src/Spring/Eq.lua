-- created by bhristt (June 3rd 2021)
-- updated (November 9th 2023)
--!nocheck


export type Spring = {

	-- init values
	Mass: number;
	Damping: number;
	Constant: number;
	InitialOffset: number;
	InitialVelocity: number;
	ExternalForce: number;
	AdvancedObjectStringEnabled: boolean,

	-- cache values
	StartTick: number;

	-- function and connection
	F: DifEqFunctionTable | nil;
};


export type DifEqFunctionTable = {

	-- contains functions for offset, velocity, and acceleration
	Offset: (number) -> number;
	Velocity: (number) -> number;
	Acceleration: (number) -> number;
};


local Functions = {}


function OverDamping(m: number, a: number, k: number, y0: number, v0: number, f:number): DifEqFunctionTable -- Two solutions r1 and r2; normal solution for second order DE
	local delta = a*a - 4*k/m;
	local d = -1/2;
	local w1 = a + math.sqrt(delta);
	local w2 = a - math.sqrt(delta);
	local r1, r2 = d*w1, d*w2;
	local c1, c2 = (r2*y0 - v0)/(r2 - r1), (r1*y0 - v0)/(r1 - r2);
	local yp = f/k;

	return {
		Offset = function(t)
			return c1*math.exp(r1*t) + c2*math.exp(r2*t) + yp;
		end;
		Velocity = function(t)
			return c1*r1*math.exp(r1*t) + c2*r2*math.exp(r2*t);
		end;
		Acceleration = function(t)
			return c1*r1*r1*math.exp(r1*t) + c2*r2*r2*math.exp(r2*t);
		end;
	};
end


function CriticalDamping(m: number, a: number, k: number, y0: number, v0: number, f: number): DifEqFunctionTable -- Repeated solution; must add a multiple of t
	local r = -a/2;
	local c1, c2 = y0, v0 - r*y0
	local yp = f/k;

	return {
		Offset = function(t)
			return math.exp(r*t)*(c1 + c2*t) + yp;
		end;
		Velocity = function(t)
			return math.exp(r*t)*(c2*r*t + c1*r + c2);
		end;
		Acceleration = function(t)
			return r*math.exp(r*t)*(c2*r*t + c1*r + 2*c2);
		end;
	};
end


function UnderDamping(m: number, a: number, k: number, y0: number, v0: number, f: number): DifEqFunctionTable -- Imaginary solution turned into sin + cos using e^(ix) = cos(x) + isin(x)
	local delta = a*a - 4*k/m;
	local r = -a/2;
	local s = math.sqrt(-delta);
	local c1, c2 = y0, (v0 - (r*y0))/s;
	local yp = f/k;

	return {
		Offset = function(t)
			return math.exp(r*t)*(c1*math.cos(s*t) + c2*math.sin(s*t)) + yp;
		end;
		Velocity = function(t)
			return -math.exp(r*t)*((c1*s - c2*r)*math.sin(s*t) + (-c2*s - c1*r)*math.cos(s*t));
		end;
		Acceleration = function(t)
			return -math.exp(r*t)*((c2*s*s + 2*c1*r*s - c2*r*r)*math.sin(s*t) + (c1*s*s - 2*c2*r*s - c1*r*r)*math.cos(s*t));
		end;
	};
end


function Functions.F(Spring: Spring): DifEqFunctionTable
	local y0, v0, f = Spring.InitialOffset, Spring.InitialVelocity, Spring.ExternalForce;
	local m, a, k = Spring.Mass, Spring.Damping, Spring.Constant;
	local delta = a*a - 4*k/m;

	if delta > 0 then
		return OverDamping(m, a, k, y0, v0, f);
	elseif delta == 0 then
		return CriticalDamping(m, a, k, y0, v0, f);
	else
		return UnderDamping(m, a, k, y0, v0, f);
	end
end


return Functions;