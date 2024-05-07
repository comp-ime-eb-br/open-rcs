import math
import numpy as np
# from icecream import *

from rcs_functions import *

INTERFACE = True

def rcs_monostatic(input_model, freq, corr, delstd, ipol, pstart, pstop, delp, tstart, tstop, delt, Rs):
    # 1: radar frequency in MHz
    freq = freq*10**6
    wave = 3e8 / freq
    ic(wave)
    # 2: correlation distance 
    corel = float(corr)/wave
    ic(corel)
    # 3: standard deviation
    [bk,cfac1,cfac2,rad,Lt,Nt] = getStandardDeviation(delstd,corel,wave)
    ic([bk,cfac1,cfac2,rad,Lt,Nt])
    # 4: incident wave polarization
    [pol,Et,Ep] = getPolarization(ipol)
    ic([pol,Et,Ep])
    Co=1  # wave amplitude at all vertices
    
    # processing coordinate data 
    x, y, z, xpts, ypts, zpts, nverts = read_coordinates(input_model)
    ic(x, y, z, xpts, ypts, zpts, nverts)
    nfc, node1, node2, node3, iflag, ilum, Rs, ntria = read_facets(input_model, Rs)
    ic(nfc, node1, node2, node3, iflag, ilum, Rs, ntria)
    vind = create_vind(node1, node2, node3)
    ic(vind)
    r = calculate_r(x, y, z, nverts)
    ic(r)
    
    # pattern loop
    Area, alpha, beta, N, d, ip, it = calculate_values(pstart, pstop, delp, tstart, tstop, delt, ntria, rad)
    # ic(pstart, pstop, delp, tstart, tstop, delt, ntria, rad) #entrada
    # ic(Area, alpha, beta, N, d, ip, it) #saída aleatória tirando ip e it
    # get edge vectors and normals from edge cross products
    A,B,C,N,d,ss,Area, Nn, N, beta,alpha =  productVector(ntria,N,r,d,Area,alpha,beta,vind)
    ic(A,B,C,N,d,ss,Area, Nn, N, beta,alpha)
    phi, theta, U,V,W,e0, Sth,Sph = otherVectorComponents(ip,it,np)
    ic(phi, theta, U,V,W,e0, Sth,Sph)
    # ic(phi, theta, U,V,W,e0, Sth,Sph)
    
    for i1 in range(ip):
        for i2 in range(it):
            phi[i1,i2]=pstart+(i1)*delp
            phr=phi[i1,i2]*rad
            theta[i1,i2]=tstart+(i2)*delt
            thr=theta[i1,i2]*rad
            # global angles and direction cosine
            U, V, W, D0, uu, vv, ww, u, v, w = globalAngles(U,V,W,thr,phr,i1,i2)
            # ic(U, V, W, D0, uu, vv, ww, u, v, w)
            # spherical coordinate system radial unit vector
            R=np.array([u,v,w])
            # ic(R)
            # incident field in global cartesian coordinates
            e0  = incidentFieldCartesian(uu,vv,ww,e0,Et,phr,Ep)
            # ic(e0)
            # begin loop over triangles
            sumt=0
            sump=0
            sumdt=0
            sumdp=0
            for m in range(ntria): # test to see if front face is illuminated
                ndotk=np.dot(N[m,:],np.transpose(R))
                if iflag==0:
                    if (ilum[m]==1 and ndotk>=1e-5) or ilum[m]==0:
                        # local direction cosine
                        u2, v2, w2, T1, T2 = diretionCosines(alpha, beta, D0, m)

                        # find spherical angles in local coordinates
                        th2, phi2 = sphericalAngles(u2,v2,w2)

                        # phase at the three vertices of triangle m; monostatic RCS needs "2"
                        Dp,Dq,Do = phaseVerticeTriangle(x,y,z,vind,bk,m,u,v,w)
                        # incident field in local cartesian coordinates (stored in e2)
                        e1=np.dot(T1,np.transpose(np.conj(e0)))
                        e2=np.dot(T2,e1)

                        # incident field in local spherical coordinates
                        Et2, Ep2 = incidentFieldSphericalCoordinates(th2,e2,phi2)
                        # ic(Et2, Ep2)
                        # reflection coefficients (Rs is normalized to eta0)
                        perp, para = reflectionCoefficients(Rs, th2, m)
                        
                        # surface current components in local Cartesian coordinates
                        Jx2=(-Et2*math.cos(phi2)*para+Ep2*math.sin(phi2)*perp);   # math.cos(th2) removed
                        Jy2=(-Et2*math.sin(phi2)*para-Ep2*math.cos(phi2)*perp);   # math.cos(th2) removed
                        # ic(Jx2,Jy2)
                        # area integral for general case
                        DD, expDo, expDp, expDq = areaIntegral(Dq, Dp,Do)

                        Ic = calculate_Ic(Dp,Dq,Do,N, Nt,Area, expDo,Co,Lt,DD,expDq, m, expDp)
                        sumt,sump,sumdp,sumdt = calculaCampos(Area, cfac2, corel, th2, wave,Jy2,Ic,uu,vv,ww,phr,sumt,sump,sumdt,sumdp, m, Jx2, T1, T2)
            Sth, Sph = calculateSth_Sph(cfac1,sumt,sump,sumdt,wave, Sth, Sph, i1, i2, sumdp) 
    Smax,Lmax, Lmin,Sth, Sph = parametrosGrafico(np,Sth,Sph)

    # generate result files
    setFontOption()
    fig_name = plot_triangle_model(input_model, vind, x, y, z, xpts, ypts, zpts, nverts, ntria, node1, node2, node3, nfc)
    param = plotParameters("Monostatic",freq,wave,corr,delstd, pol,ntria,pstart,pstop,delp,tstart,tstop,delt)
    now, file_name = generateResultFiles(theta, Sth, phi,Sph, param, ip, Sph)
    plot_name = finalPlot(ip, it,phi, wave,theta, Lmin,Lmax,Sth,Sph,U,V,now, input_model, "Monostatic")
    
    return plot_name, fig_name, file_name


if not INTERFACE:
    # open input data file and gather parameters
    input_data_file = "input_files\\input_data_file_monostatic.dat"
    params = open(input_data_file, 'r')
    param_list = []
    for line in params:
        line=line.strip("\n")
        if not line.startswith("#"):
            if line.isnumeric(): param_list.append(int(line))
            else: param_list.append(line)
    input_model, freq, corr, delstd, ipol, rs, pstart, pstop, delp, tstart, tstop, delt = param_list
    params.close()
    rcs_monostatic(input_model, freq, corr, delstd, ipol, pstart, pstop, delp, tstart, tstop, delt, rs) 