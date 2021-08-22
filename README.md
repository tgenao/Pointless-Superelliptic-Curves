This code was written for a course on algebraic curves taught by Pete L. Clark in Fall 2020. It is written in Magma.

The motivation: given positive integers n and g, for which prime powers q can we find examples of pointless superelliptic curves of genus g over F_q given by an equation of the form y^n-f(x)?

This code does the following: 

1. Uses Weil bounds on rational points to bound any possible q for which our superelliptic curve has no rational points. 
2. Determine degrees d of f(x) for which y^n-f(x) has genus g. First we get the d which come from lower-bounding the genus formula, then throw out d with gcd(n,d)=1 (such d will have that the infinite place of the rational function field is totally ramified in our superelliptic function field, whence induces a rational point above). Then we throw out the d which fail the genus formula.
3. For each d above, for one prime power q at a time, only considering q with n|(q-1) (so that F_q has primitive n'th roots of unity), the code then creates random separable polynomials f(x) over F_q of degree d whose leading terms are not n'th powers in F_q. Such a leading term ensures the points above the infinite place are not rational. 
    1. For each polynomial f(x) above, the code computes the image of the evaluation map for f(x). If it has an n'th power, then it picks another polynomial and repeats this step i. But if it does not have an n'th power in its image, then it returns f(x), and we may conclude that y^n-f(x) is pointless over F_q. 

This code is not exhaustive, as it picks random polynomials f(x) over F_q. 
