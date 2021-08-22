// This code was written for a course on algebraic curves taught by Pete L. Clark in Fall 2020. It is written in Magma.
// The motivation: given positive integers n and g, for which prime powers q can we find examples of pointless superelliptic curves of genus g over F_q given by an equation of the form y^n-f(x)?
// This code does the following: 
// 1. Uses Weil bounds on rational points to bound any possible q for which our superelliptic curve has no rational points. 
// 2. Determine degrees d of f(x) for which y^n-f(x) has genus g. First we get the d which come from lower-bounding the genus formula, then throw out d with gcd(n,d)=1 (such d will have that the infinite place of the rational function field is totally ramified in our superelliptic function field, whence induces a rational point above). Then we throw out the d which fail the genus formula.
// 3. For each d above, for one prime power q at a time, only considering q with n|(q-1) (so that F_q has primitive n'th roots of unity), the code then creates random separable polynomials f(x) over F_q of degree d whose leading terms are not n'th powers in F_q. Such a leading term ensures the points above the infinite place are not rational.
// 3.a For each polynomial f(x) above, the code computes the image of the evaluation map for f(x). If it has an n'th power, then it picks another polynomial and repeats this step (3.a). But if it does not have an n'th power in its image, then it returns f(x), and we may conclude that y^n-f(x) is pointless over F_q. 
// This code is not exhaustive, as it picks random polynomials f(x) over F_q. It would be interesting to make code which can do an exhaustive search in a reasonable amount of time.

// This function computes the set of n'th power elements in F_q.
NthPowers:=function(n,q)
	powerList:={};
	for a in GF(q) do
		if (a^n in powerList) eq false then
			Include(~powerList, a^n);
		end if;
	end for;
	return powerList;
end function;

// This function returns a random separable polynomial over F_q of degree d.
// It also takes as input L the n'th power list, so that the list isn't repeatedly computed when this function is repeatedly called.
RandomSepPolyNonNthPower:=function(d,q,L)
	F:=GF(q);
	R<x>:=PolynomialRing(F);
	while true do
		index:=0;
		f:=0;
		while index lt d-1 do
			f:=f+Random(F)*x^index;
			index:=index+1;
		end while;
		f:=f+Random(L)*x^d;
		if IsSeparable(f) eq true then
			return f;
		end if;
	end while;
end function;

// Given n, q, d and g, this function looks for f(x) separable of degree d such that y^n-f(x) defines a genus g pointless superelliptic curve over F_q.
// The input N is the amount of of times it will search for a polynomial f(x) satisfying these conditions, before it gives up.
Pointless:=function(n,q,d,g,N)
	NthPowersList:=NthPowers(n,q);
	nonNthPowersList:=Set(GF(q)) diff NthPowersList;
	c:=0;
	while c lt N do
		rationalPoint:=false;
		c:=c+1;
		f:=RandomSepPolyNonNthPower(d,q,nonNthPowersList);
		// We loop over all values a in F_q, checking whether f(a) is an n'th power in F_q, i.e., whether y^n=f(a) has a solution y in F_q.
		// If no solution to y^n=f(a) is found for some a, it returns f(x).
		for a in GF(q) do
			if (Evaluate(f, a) in NthPowersList) eq true then
				rationalPoint:=true;
				break;
			end if;
		end for;
		if rationalPoint eq false then
			return f;
		end if;
	end while;
	return "Not found!";
end function;

// This function determines the possible degrees of f(x) for which y^n=f(x) may have genus g.
PossibleDegrees:=function(n,g)
DegList:=[];
	for d in [1..2+Floor(2*g/(n-1))] do
		if GCD(d,n) gt 1 then
			if ( ( (n-1)*(d-2) + n - GCD(n,d) )/2 - g) eq 0 then
				Append(~DegList, d);
			end if;
		end if;
	end for;
	return DegList;
end function;

// This function returns Weil bounds in terms of a given genus.
Weil:=function(g)
	return 2*g^2-1+2*g*Sqrt(g^2-1);
end function;

// Given n and g, this function will compute possible degrees d of f(x) for which y^n=f(x) may have genus g. Then for each d, it will use the Pointless function to search over F_q for such a polynomial f(x), only for q less than the Weil bound.
// Q is the least prime the function will check for polynomials over.
// N will be the upper bound on the number of times it searches for a polynomial in degree d over F_q.
PointlessSearchNoD:=function(n,g,Q,N)
	"Looking for examples of pointless curves of the form y^" cat IntegerToString(n) cat "=f(x) of genus " cat IntegerToString(g);
	D:=PossibleDegrees(n,g);
	"For q > " cat IntegerToString(Ceiling(Weil(g))) cat " one is guaranteed rational points";
	"Possible degrees of f(x) for which y^" cat IntegerToString(n) cat "-f(x) has genus " cat IntegerToString(g) cat " and \infty does not totally ramify: d in", D;
	for d in D do
		"When the degree of f(x) is " cat IntegerToString(d) cat ":";
		for q in [Q..Floor(Weil(g))] do
			if IsPrimePower(q) eq true then
				if q mod n eq 1 then
					"q = " cat IntegerToString(q) cat " and f(x) = ",Pointless(n,q,d,g,N);
					//SetOutputFile("superPointlessList.txt");
					//q, Pointless(n,q,d,g,N);
					//UnsetOutputFile();
				end if;
			end if;
		end for;
	end for;
	return "Finished search, checking up to " cat IntegerToString(N) cat " polynomials for each pair (degree, F_q).";
end function;

// Example calculation:
PointlessSearchNoD(2,3,2,1000000);
// Example output:
	// Looking for examples of pointless curves of the form y^2=f(x) of genus 2
	// For q > 14 one is guaranteed rational points
	// Possible degrees of f(x) for which y^2-f(x) has genus 2 and infty does not totally ramify: d in [ 6 ]
	// When the degree of f(x) is 6:
	// q = 3 and f(x) =  2*x^6 + 2*x^3 + x^2 + x + 2
	// q = 5 and f(x) =  2*x^6 + 3*x^4 + 2*x^3 + 4*x^2 + 3*x + 3
	// q = 7 and f(x) =  6*x^6 + 6
	// q = 9 and f(x) =  $.1*x^6 + $.1^3*x^4 + $.1*x^2 + $.1^7
	// q = 11 and f(x) =  10*x^6 + 5*x^4 + 5*x^2 + 10
	// q = 13 and f(x) =  Not found!
	// Finished search, checking up to 1000000 polynomials for each pair (degree, F_q).