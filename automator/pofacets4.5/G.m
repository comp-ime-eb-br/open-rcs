function g = G(n,w)
% filename: G.m
% Project: POFACETS
% Description:  This program calculates the recursive function G.
% Author:  Prof. David C. Jenn and Elmo E. Garrido Jr.
% Date: 24 July 2000
% Place: NPS

	jw = j*w;
   g = (exp(jw) - 1)/jw;
  	if n > 0 
  		for m = 1:n
   		go = g;
    		g = (exp(jw) - n*go)/jw;
   	end
  	end
