function f = fact(m)
% filename: fact.m
% Project: POFACETS
% Description: This function calculates the factorial of a  number m
% Author:  Prof. David C. Jenn and Elmo E. Garrido Jr.
% Date:  25 July 2000
% Place: NPS

	f = 1;
	if m >= 1
		for n = 1:m
			f = f*n;
		end
	end   