import math, cmath
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime

from rcs_functions import *

# open input data file and gather parameters
# input_model="PLATE"
input_data_file = "input_data_file_bistatic.dat"
params = open(input_data_file, 'r')
param_list = []
for line in params:
    line=line.strip("\n")
    if not line.startswith("#"):
        if line.isnumeric(): param_list.append(int(line))
        else: param_list.append(line)
input_model, freq, corr, delstd, ipol, pstart, pstop, delp, tstart, tstop, delt, thetai, fii = param_list
params.close()

# 1: radar frequency
wave = 3e8 / freq
# surface roughness of model is approximated by correlation distance and standard deviation (for smooth surface, both are 0)
# 2: correlation distance 
corel = corr/wave
# 3: standard deviation
[bk,cfac1,cfac2,rad,Lt,Nt] = getStandardDeviation(delstd,corel,wave)
# 4: incident wave polarization
[pol,Et,Ep] = getPolarization(ipol)
Co=1  # wave amplitude at all vertices
# processing coordinate data 
x, y, z, xpts, ypts, zpts, nverts = read_coordinates(input_model)
nfc, node1, node2, node3, iflag, ilum, Rs, ntria = read_facets(input_model)
vind = create_vind(node1, node2, node3)
r = calculate_r(x, y, z, nverts)
# plot font options
setFontOption()
# plot model before simulation
fig = plt.figure(1,[7,4])
fig.suptitle(f'RCS Monostatic Simulation of Target: {input_model}')
# plot triangle model
ilabv ='n'; ilabf='n' # label vertices and faces
ax = fig.add_subplot(1,2,1, projection='3d')
[xmin, ymin, zmin, xmax, zmax, ymax] = plot_triangle_model(ax, vind, x, y, z, xpts, ypts, zpts, nverts, ntria, node1, node2, node3, nfc, ilabv, ilabf)
# plot parameters info
param = plotParameters(fig,freq,wave,corr,delstd, pol,ntria,pstart,pstop,delp,tstart,tstop,delt)
# bpos = plt.axes([0.75, 0.2, 0.2, 0.075])
# bstart = Button(bpos, 'Start Simulation')
# bstart.on_clicked()
# bpos = plt.axes([0.75, 0.1, 0.2, 0.075])
# bstop = Button(bpos, 'Cancel Simulation')
# bstop.on_clicked()
plt.show()
ax.set_xlim(xmin, xmax)
ax.set_ylim(ymin, ymax)
ax.set_zlim(zmin, zmax)
# pattern loop
Area, alpha, beta, N, d, ip, it ,cpi,spi,sti,cti,ui,vi,wi,D0i,uui,vvi,wwi,Ri = bi_calculate_values(pstart, pstop, delp, tstart, tstop, delt, ntria, rad,fii,thetai)
# get edge vectors and normals from edge cross products
A,B,C,N,d,ss,Area, Nn, N, beta,alpha =  productVector(ntria,N,r,d,Area,alpha,beta,vind)
phi, theta, U,V,W,e0, Sth,Sph = otherVectorComponents(ip,it,np)

e0 = bi_incidentFieldCartesian(uui,vvi,wwi,cpi,spi,Et,Ep,e0)

for i1 in range(ip):
    for i2 in range(it):
        phi[i1,i2]=pstart+(i1)*delp
        phr=phi[i1,i2]*rad
        theta[i1,i2]=tstart+(i2)*delt
        thr=theta[i1,i2]*rad
        # global angles and direction cosine
        U, V, W, D0, uu, vv, ww, u, v, w = globalAngles(U,V,W,thr,phr,i1,i2)
        # spherical coordinate system radial unit vector
        R=np.array([u,v,w])
        # incident field in global cartesian coordinates
        # begin loop over triangles
        sumt=0
        sump=0
        sumdt=0
        sumdp=0
        for m in range(ntria): # test to see if front face is illuminated
            ndotk=np.dot(N[m,:],np.transpose(R))
            nidotk=np.dot(N[m,:],np.transpose(Ri))
            if iflag==0:
                if (ilum[m]==1 and nidotk>=0) or ilum[m]==0 or iflag==1:
                    # local direction cosine
                    ui2, vi2, wi2, T1, T2 = diretionCosines(alpha, beta, D0i, m)

                    # find spherical angles in local coordinates
                    thi2, fii2, cpi2, spi2, sti2, cti2 = bi_sphericalAngles(ui2,vi2,wi2)

                    #Transform observation quantities
                    u2, v2, w2, T1, T2 = diretionCosines(alpha, beta, D0, m)

                    th2, phi2, cp2, sp2, st2, ct2 = bi_sphericalAngles(u2,v2,w2)
                    # phase at the three vertices of triangle m; biestatic RCS needs "2"
                    Dp,Dq,Do = bi_phaseVerticeTriangle(x,y,z,vind,bk,m,u,v,w,ui,vi,wi)
                    # incident field in local cartesian coordinates (stored in e2)
                    e1=np.dot(T1,np.transpose(e0))
                    e2=np.dot(T2,e1)

                    # incident field in local spherical coordinates
                    Et2, Ep2 = bi_incidentFieldSphericalCoordinates(cpi2, cti2, sti2, spi2, e2)

                    # reflection coefficients (Rs is normalized to eta0)
                    perp, para = reflectionCoefficients(Rs, th2, m)

                    # surface current components in local Cartesian coordinates
                    Jx2=(-Et2*cpi2*para+Ep2*spi2*perp);   # math.cos(th2) removed
                    Jy2=(-Et2*spi2*para-Ep2*cpi2*perp);   # math.cos(th2) removed

                    # area integral for general case
                    DD, expDo, expDp, expDq = areaIntegral(Dq, Dp,Do)

                    Ic = calculate_Ic(Dp,Dq,Do,N, Nt,Area, expDo,Co,Lt,DD,expDq, m, expDp)
                    sumt,sump,sumdp,sumdt = calculaCampos(Area, cfac2, corel, th2, wave,Jy2,Ic,uu,vv,ww,phr,sumt,sump,sumdt,sumdp, m, Jx2, T1, T2)
        Sth, Sph = calculateSth_Sph(cfac1,sumt,sump,sumdt,wave, Sth, Sph, i1, i2, sumdp) 
Smax,Lmax, Lmin,Sth, Sph = parametrosGrafico(np,Sth,Sph)

# generate result files
now = generateResultFilesBistatic(theta, Sth, phi, Sph, param, ip, Sph)

# final plots
finalPlotBistatic(ip, it,phi, wave,theta, Lmin,Lmax,Sth,Sph,U,V,now, input_model)