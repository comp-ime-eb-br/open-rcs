import math, cmath
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime

SMALL_SIZE = 8
MEDIUM_SIZE = 10
BIGGER_SIZE = 12

def getPolarization(incidentPolarization):
    if incidentPolarization == 0: # Theta-polarized (TM-z)
        pol_aux = 'TM-z'
        Et_aux = 1 + 1j * 0
        Ep_aux = 0 + 1j * 0
        return [pol_aux,Et_aux,Ep_aux]
    elif incidentPolarization == 1: # Phi-polarized (TE-z)
        pol_aux = 'TE-z'
        Et_aux = 0 + 1j * 0   
        Ep_aux = 1 + 1j * 0
        return [pol_aux,Et_aux,Ep_aux]
    else:
        raise ValueError('Invalid input')

def getStandardDeviation(delstd,corel,wave):
    delsq = delstd ** 2
    bk = 2 * np.pi / wave
    cfac1 = np.exp(-4 * bk ** 2 * delsq)
    cfac2 = 4 * np.pi * (bk * corel) ** 2 * delsq
    rad = np.pi / 180
    Lt = 0.05  # taylor series region
    Nt = 5 # number of terms in Taylor series
    return[bk,cfac1,cfac2,rad,Lt,Nt]

def setFontOption(fontSize=SMALL_SIZE, axesTitle=MEDIUM_SIZE, axesLabel=SMALL_SIZE, xtickLabel=SMALL_SIZE, 
ytickLabel=SMALL_SIZE, legendSize=SMALL_SIZE, figureTitle=BIGGER_SIZE):
    plt.rc('font', size=fontSize)          # controls default text sizes
    plt.rc('axes', titlesize=axesTitle)    # fontsize of the axes title
    plt.rc('axes', labelsize=axesLabel)     # fontsize of the x and y labels
    plt.rc('xtick', labelsize=xtickLabel)    # fontsize of the tick labels
    plt.rc('ytick', labelsize=ytickLabel)    # fontsize of the tick labels
    plt.rc('legend', fontsize=legendSize)    # legend fontsize
    plt.rc('figure', titlesize=figureTitle)  

def read_coordinates(input_model):
    fname = "./coordinates.txt"
    coordinates = np.loadtxt(fname)
    xpts = coordinates[:, 0]
    ypts = coordinates[:, 1]
    zpts = coordinates[:, 2]

    x = xpts
    y = ypts
    z = zpts

    nverts = len(xpts)
    return x, y, z, xpts, ypts, zpts, nverts

def read_facets(input_model,rs):
    fname2 = "./facets.txt"
    facets = np.loadtxt(fname2)
    nfc = facets[:, 0]
    node1 = facets[:, 1].astype(int)
    node2 = facets[:, 2].astype(int)
    node3 = facets[:, 3].astype(int)
    iflag = 0
    ilum = facets[:, 4]
    Rs = np.full(facets[:, 4].shape, rs)
    ntria = len(node3)
    return nfc, node1, node2, node3, iflag, ilum, Rs, ntria

def create_vind(node1, node2, node3):
    vind = np.empty([len(node3), 3])
    for i in range(len(node3)):
        pts = np.array([node1[i], node2[i], node3[i]])
        vind[i, :] = pts
    vind = vind.astype(int)
    return vind

def calculate_r(x, y, z, nverts):
    r = np.zeros([nverts, 3], np.double)
    for i in range(nverts):
        r[i, :] = [x[i], y[i], z[i]]
    return r

def plot_triangle_model(input_model, vind, x, y, z, xpts, ypts, zpts, nverts, ntria, node1, node2, node3, nfc):
    fig = plt.figure(1)
    fig.suptitle(f'Triangle Model of Target: {input_model}')
    ilabv ='n'; ilabf='n' # label vertices and faces
    ax = fig.add_subplot(1,1,1, projection='3d')
    
    for i in range(ntria):
        X = [x[vind[i, 0]-1], x[vind[i, 1]-1], x[vind[i, 2]-1], x[vind[i, 0]-1]]
        Y = [y[vind[i, 0]-1], y[vind[i, 1]-1], y[vind[i, 2]-1], y[vind[i, 0]-1]]
        Z = [z[vind[i, 0]-1], z[vind[i, 1]-1], z[vind[i, 2]-1], z[vind[i, 0]-1]]
        ax.plot(X, Y, Z)
    #ax.set_title(f'Triangle Model of Target:')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_zlabel('z')
    xmax = max(xpts)
    xmin = min(xpts)
    ymax = max(ypts)
    ymin = min(ypts)
    zmax = max(zpts)
    zmin = min(zpts)
    dmax = max([xmax, ymax, zmax])
    dmin = min([xmin, ymin, zmin])
    # this is to avoid both a max and min of zero in any one dimension
    xmax = dmax; ymax = dmax; zmax = dmax
    xmin = dmin; ymin = dmin; zmin = dmin
    
    if ilabv == 'y':
        for i in range(nverts):
            ax.text(x[i]-max(x)/20, y[i]-max(y)/20, z[i], str(i+1))
    
    if ilabf == 'y':
        for i in range(ntria):
            xav = (xpts[node1[i]-1] + xpts[node2[i]-1] + xpts[node3[i]-1]) / 3
            yav = (ypts[node1[i]-1] + ypts[node2[i]-1] + ypts[node3[i]-1]) / 3
            zav = (zpts[node1[i]-1] + zpts[node2[i]-1] + zpts[node3[i]-1]) / 3
            ax.text(xav, yav, zav, str(nfc[i]))
    # return xmin, ymin, zmin, xmax, ymax, zmax

    # plot parameters
    # param = plotParameters("Monostatic",freq,wave,corr,delstd, pol,ntria,pstart,pstop,delp,tstart,tstop,delt)
    ax.set_xlim(xmin, xmax)
    ax.set_ylim(ymin, ymax)
    ax.set_zlim(zmin, zmax)
    
    # save plots
    now = datetime.now().strftime("%Y%m%d%H%M%S")
    fig_name = "./results/"+"temp"+"_"+now+".jpg"
    extent = ax.get_window_extent().transformed(fig.dpi_scale_trans.inverted())
    fig.savefig(fig_name, bbox_inches=extent)
    plt.close()
    
    return fig_name

def diretionCosines(alpha, beta, D0,m):
                        T1=np.array([[math.cos(alpha[m]),  math.sin(alpha[m]),   0],
                                        [-math.sin(alpha[m]), math.cos(alpha[m]),   0],
                                        [0,                   0,                    1]])
                        T2=np.array([[math.cos(beta[m]), 0, -math.sin(beta[m])],
                                        [0,                 1, 0],
                                        [math.sin(beta[m]), 0, math.cos(beta[m])]])
                        D1=np.dot(T1,np.transpose(D0))
                        D2=np.dot(T2,D1)
                        u2=D2[0]
                        v2=D2[1]
                        w2=D2[2]
                        return u2, v2, w2, T1, T2

def calculate_values(pstart, pstop, delp, tstart, tstop, delt, ntria, rad):
    def calculate_ip():
        if delp == 0:
            return int((pstop - pstart)) + 1
        else:
            return int((pstop - pstart) / delp) + 1
    
    def calculate_it():
        if delt == 0:
            return int((tstop - tstart)) + 1
        else:
            return int((tstop - tstart) / delt) + 1
    
    def calculate_phr0():
        if pstart == pstop:
            return pstart * rad
    
    def calculate_thr0():
        if tstart == tstop:
            return tstart * rad
    
    ip = calculate_ip()
    it = calculate_it()
    phr0 = calculate_phr0()
    thr0 = calculate_thr0()
    
    Area = np.empty(ntria, np.double)
    alpha = np.empty(ntria, np.double)
    beta = np.empty(ntria, np.double)
    N = np.empty([ntria, 3], np.double)
    d = np.empty([ntria, 3], np.double)
    
    return Area, alpha, beta, N, d, ip, it 

def bi_calculate_values(pstart, pstop, delp, tstart, tstop, delt, ntria, rad, fii,thetai):
    # Calcula os valores das funções trigonométricas
    cpi = np.cos(fii* np.pi / 180.0)
    spi = np.sin(fii* np.pi / 180.0)
    sti = np.sin(thetai* np.pi / 180.0)
    cti = np.cos(thetai* np.pi / 180.0)

    # Calcula os valores dos vetores
    ui = sti * cpi
    vi = sti * spi
    wi = cti
    D0i = np.array([ui, vi, wi])

    uui = cti * cpi
    vvi = cti * spi
    wwi = -sti
    Ri = -np.array([ui, vi, wi])

    def calculate_ip():
        if delp == 0:
            return int((pstop - pstart)) + 1
        else:
            return int((pstop - pstart) / delp) + 1
    
    def calculate_it():
        if delt == 0:
            return int((tstop - tstart)) + 1
        else:
            return int((tstop - tstart) / delt) + 1
    
    def calculate_phr0():
        if pstart == pstop:
            return pstart * rad
    
    def calculate_thr0():
        if tstart == tstop:
            return tstart * rad
    
    ip = calculate_ip()
    it = calculate_it()
    phr0 = calculate_phr0()
    thr0 = calculate_thr0()
    
    Area = np.empty(ntria, np.double)
    alpha = np.empty(ntria, np.double)
    beta = np.empty(ntria, np.double)
    N = np.empty([ntria, 3], np.double)
    d = np.empty([ntria, 3], np.double)

    
    return Area, alpha, beta, N, d, ip, it ,cpi,spi,sti,cti,ui,vi,wi,D0i,uui,vvi,wwi,Ri

def globalAngles(U,V,W,thr,phr,i1,i2):
            u=math.sin(thr)*math.cos(phr)
            v=math.sin(thr)*math.sin(phr)
            w=math.cos(thr)
            U[i1,i2]=u 
            V[i1,i2]=v
            W[i1,i2]=w
            D0=np.array([u,v,w])
            uu=math.cos(thr)*math.cos(phr)
            vv=math.cos(thr)*math.sin(phr)
            ww=-math.sin(thr)
            return U, V, W, D0, uu, vv, ww, u, v, w

def incidentFieldCartesian(uu,vv,ww,e0,Et,phr,Ep):
            e0[0]=uu*Et-np.sin(phr)*Ep
            e0[1]=vv*Et+math.cos(phr)*Ep
            e0[2]=ww*Et
            return e0

def bi_incidentFieldCartesian(uu,vv,ww,cpi,spi,Et,Ep,e0):
    e0[0]=uu*Et-spi*Ep
    e0[1]=vv*Et+cpi*Ep
    e0[2]=ww*Et
    return e0

def sphericalAngles(u2,v2,w2):
                        th2=math.asin(np.sqrt(u2**2+v2**2)*np.sign(w2))
                        phi2=math.atan2(v2,u2+1e-10)
                        if(v2==u2+1e-10==0): #porque precisou disso?
                            phi2=0
                        return th2, phi2

def bi_sphericalAngles(ui2,vi2,wi2):
    sti2=np.sqrt(ui2**2+vi2**2)*np.sign(wi2)
    cti2=np.sqrt(1-sti2**2)
    thi2=math.acos(cti2)
    phii2=math.atan2(vi2,ui2+1e-10)
    if(vi2==ui2+1e-10==0): #porque precisou disso?
        phii2=0
    return thi2, phii2, np.cos(phii2), np.sin(phii2), sti2, cti2

def phaseVerticeTriangle(x,y,z,vind,bk,m,u,v,w):
                        
                        Dp=2*bk*((x[vind[m,0]-1]-x[vind[m,2]-1])*u+
                                (y[vind[m,0]-1]-y[vind[m,2]-1])*v+
                                (z[vind[m,0]-1]-z[vind[m,2]-1])*w)
                        Dq=2*bk*((x[vind[m,1]-1]-x[vind[m,2]-1])*u+
                                (y[vind[m,1]-1]-y[vind[m,2]-1])*v+
                                (z[vind[m,1]-1]-z[vind[m,2]-1])*w)
                        Do=2*bk*(x[vind[m,2]-1]*u + y[vind[m,2]-1]*v + z[vind[m,2]-1]*w)
                        return(Dp,Dq,Do)

def bi_phaseVerticeTriangle(x,y,z,vind,bk,m,u,v,w,ui,vi,wi):
    Dp=bk*((x[vind[m,0]-1]-x[vind[m,2]-1])*(u+ui)+
            (y[vind[m,0]-1]-y[vind[m,2]-1])*(v + vi)+
            (z[vind[m,0]-1]-z[vind[m,2]-1])*(w + wi))
    Dq=bk*((x[vind[m,1]-1]-x[vind[m,2]-1])*(u+ui)+
            (y[vind[m,1]-1]-y[vind[m,2]-1])*(v + vi)+
            (z[vind[m,1]-1]-z[vind[m,2]-1])*(w + wi))
    Do=bk*(x[vind[m,2]-1]*(u+ui) + y[vind[m,2]-1]*(v + vi) + z[vind[m,2]-1]*(w - wi))
    return(Dp,Dq,Do)

def G(n,w):
                        jw=1j*w
                        g=(np.exp(jw)-1)/jw
                        if n > 0:
                            for m in range(1,n+1):
                                go=g
                                g=(cmath.exp(jw)-n*go)/jw
                        return g

def reflectionCoefficients(Rs, th2, m):
                        perp=-1/(2*Rs[m]*math.cos(th2)+1)  #local TE polarization
                        para=0  #local TM polarization
                        if (2*Rs[m]+math.cos(th2))!=0:
                            para=-math.cos(th2)/(2*Rs[m]+math.cos(th2))
                        return perp, para

def incidentFieldSphericalCoordinates(th2,e2,phi2):
                        Et2=e2[0]*math.cos(th2)*math.cos(phi2)+e2[1]*math.cos(th2)*math.sin(phi2)-e2[2]*math.sin(th2)
                        Ep2=-e2[0]*math.sin(phi2)+e2[1]*math.cos(phi2)
                        return Et2, Ep2

def bi_incidentFieldSphericalCoordinates(cpi2, cti2, sti2,spi2,e2):
                        Et2=e2[0]*cti2*cpi2+e2[1]*cti2*spi2-e2[2]*sti2
                        Ep2=-e2[0]*spi2+e2[1]*cpi2
                        return Et2, Ep2


def finalPlot(ip,it,phi, wave,theta, Lmin,Lmax,Sth,Sph,U,V,now,input_model,mode):
    if ip==1:
        plt.figure(1)
        plt.suptitle(f"RCS Simulation IR Signature - {mode}")
        plt.title(f"target: {input_model}   solid: theta     dashed: phi     phi= {phi[0][0]}    wave (m): {wave}")
        plt.xlabel("Monostatic Angle, theta (deg)")
        plt.ylabel("RCS (dBsm)")
        plt.axis([np.min(theta),np.max(theta),Lmin,Lmax])
        plt.plot(theta[0],Sth[0])
        plt.plot(theta[0],Sph[0],linestyle="dashed")
        plt.grid(True)
        
    if it==1:
        plt.figure(1)
        plt.suptitle(f"RCS Simulation IR Signature - {mode}")
        plt.title(f"target: {input_model}   solid: theta     dashed: phi     theta= {theta[0][0]}    wave (m): {wave}")
        plt.xlabel('Monostatic Angle, phi (deg)')
        plt.ylabel('RCS (dBsm)')
        plt.axis([np.min(phi), np.max(phi), Lmin, Lmax])
        plt.plot(phi[0],Sth[0])
        plt.plot(phi[0],Sph[0],linestyle="dashed")
        plt.grid(True)
        
    if ip>1 and it>1:
        fig = plt.figure(1)
        fig.suptitle(f"RCS Simulation IR Signature - {mode}")
        
        ax=fig.add_subplot(2,3,2)
        cp=ax.contour(U, V, Sth)
        ax.set_title('RCS-theta')
        ax.set_xlabel('U')
        ax.set_ylabel('V')
        ax.axis('square')
        cbar=fig.colorbar(cp)
        cbar.set_label('RCS (dBsm)')
        
        bx=fig.add_subplot(2,3,5)
        cp=bx.contour(U, V, Sph)
        bx.set_title('RCS-phi')
        bx.set_xlabel('U')
        bx.set_ylabel('V')
        bx.axis('square')
        cbar=fig.colorbar(cp)
        cbar.set_label('RCS (dBsm)')
        
        fig.subplots_adjust(wspace=0)
        
    plot_name = "./results/"+"temp"+"_"+now+".png"
    plt.savefig(plot_name)
    # plt.show()
    plt.close()
    return plot_name

def generateResultFiles(theta, Sth, phi,Sphm, param, ip, Sph):
    now = datetime.now().strftime("%Y%m%d%H%M%S")
    file_name = "./results/"+"temp"+"_"+now+".dat"
    result_file = open(file_name, 'w')

    result_file.write("RCS SIMULATOR RESULTS "+now+"\n")
    result_file.write("\nSimulation Parameters:\n"+param)
    result_file.write("\nSimulation Results IR Signature:")
    result_file.write("\nTheta (deg):\n")
    for i1 in range(ip):
        result_file.write(str(theta[i1])+"\n")
    result_file.write("\nRCS Theta (dBsm):\n")
    for i1 in range(ip):
        result_file.write(str(Sth[i1])+"\n")
    result_file.write("\nPhi (deg):\n")
    for i1 in range(ip):
        result_file.write(str(phi[i1])+"\n")
    result_file.write("\nRCS Phi (dBsm):\n")
    for i1 in range(ip):
        result_file.write(str(Sph[i1])+"\n")
    return now, file_name
        
def areaIntegral(Dq, Dp,Do):
                        DD=Dq-Dp
                        expDo=cmath.exp(1j*Do)
                        expDp=cmath.exp(1j*Dp)
                        expDq=cmath.exp(1j*Dq)
                        return DD, expDo, expDp, expDq

def calculate_Ic(Dp,Dq,Do,N, Nt,Area, expDo,Co,Lt,DD,expDq, m, expDp):
                        # special case 1
                        if abs(Dp)<Lt and abs(Dq)>=Lt:
                            specialcase=1
                            sic=0
                            for n in range(Nt+1):
                                sic=sic+(1j*Dp)**n/math.factorial(n)*(-Co/(n+1)+expDq*(Co*G(n,-Dq)))
                            Ic=sic*2*Area[m]*expDo/(1j*Dq)
                        # special case 2
                        elif abs(Dp)<Lt and abs(Dq)<Lt:
                            specialcase=2
                            sic=0
                            for n in range(Nt+1):
                                for nn in range(Nt):
                                    sic=sic+(1j*Dp)**n*(1j*Dq)**nn/math.factorial(nn+n+2)*Co
                            Ic=sic*2*Area[m]*expDo
                        # special case 3
                        elif abs(Dp)>=Lt and abs(Dq)<Lt:
                            specialcase=3
                            sic=0.0
                            for n in range(Nt+1):
                                sic=sic+(1j*Dq)**n/math.factorial(n)*Co*G(n+1,-Dp)/(n+1)
                            Ic=sic*2*Area[m]*expDo*expDp
                        # special case 4
                        elif abs(Dp)>=Lt and abs(Dq)>=Lt and abs(DD)<Lt:
                            specialcase=4
                            sic=0
                            for n in range(Nt+1):
                                sic=sic+(1j*DD)**n/math.factorial(n)*(-Co*G(n,Dq)+expDq*Co/(n+1))
                            Ic=sic*2*Area[m]*expDo/(1j*Dq)
                        else:
                            specialcase=0
                            Ic=2*Area[m]*expDo*(expDp*Co/(Dp*DD)-expDq*Co/(Dq*DD)-Co/(Dp*Dq))
                        # end of special cases test
                        return Ic

def plotParameters(mode,freq,wave,corr,delstd,pol,ntria,pstart,pstop,delp,tstart,tstop,delt):
    param = f'    Mode: {mode}\n\
    Radar Frequency (GHz): {freq/1e9}\n\
    Wavelength (m): {wave}\n\
    Correlation distance (m): {corr}\n\
    Standard Deviation (m): {delstd}\n\
    Incident wave polarization: {pol}\n\
    Start phi angle (degrees): {pstart}\n\
    Stop phi angle (degrees): {pstop}\n\
    Phi increment step (degrees): {delp}\n\
    Start theta angle (degrees): {tstart}\n\
    Stop theta angle (degrees): {tstop}\n\
    Phi increment step (degrees): {delt}\n'
    return param

def calculaCampos(Area, cfac2, corel, th2, wave,Jy2,Ic,uu,vv,ww,phr,sumt,sump,sumdt,sumdp,m,Jx2, T1, T2):
                        Es0=np.empty(3,complex)
                        Es1=np.empty(3,complex)
                        Es2=np.empty(3,complex)
                        Ed0=np.empty(3,complex)
                        Ed1=np.empty(3,complex)
                        Ed2=np.empty(3,complex)
                        # add diffuse component
                        Edif=cfac2*Area[m]*(math.cos(th2)**2)*np.exp(-(corel*np.pi*math.sin(th2)/wave)**2)
                        # scattered field components for triangle m in local coordinates
                        Es2[0]=Jx2*Ic; Es2[1]=Jy2*Ic; Es2[2]=0
                        Ed2[0]=Jx2*Edif; Ed2[1]=Jy2*Edif; Ed2[2]=0
                        # transform back to global coordinates, then sum field
                        Es1=np.dot(np.transpose(T2),np.transpose(Es2))
                        Es0=np.dot(np.transpose(T1),Es1)
                        Ed1=np.dot(np.transpose(T2),np.transpose(Ed2))
                        Ed0=np.dot(np.transpose(T1),Ed1)
                        Ets=uu*Es0[0]+vv*Es0[1]+ww*Es0[2]
                        Eps=-math.sin(phr)*Es0[0]+math.cos(phr)*Es0[1]
                        Etd=uu*Ed0[0]+vv*Ed0[1]+ww*Ed0[2]
                        Epd=-math.sin(phr)*Ed0[0]+math.cos(phr)*Ed0[1]
                        # sum over all triangles to get the total field
                        sumt=sumt+Ets; sumdt=sumdt+abs(Etd)
                        sump=sump+Eps; sumdp=sumdp+abs(Epd)
                        return sumt,sump,sumdp,sumdt

def calculateSth_Sph(cfac1,sumt,sump,sumdt,wave,Sth,Sph,i1, i2, sumdp):          
            Sth[i1,i2]=10*np.log10(4*np.pi*cfac1*(np.abs(sumt)**2+np.sqrt(1-cfac1**2)*sumdt)/wave**2+1e-10)
            Sph[i1,i2]=10*np.log10(4*np.pi*cfac1*(np.abs(sump)**2+np.sqrt(1-cfac1**2)*sumdp)/wave**2+1e-10)
            return Sth, Sph

def parametrosGrafico(np,Sth,Sph):
    Smax=max(np.max(Sth),np.max(Sph))
    Lmax=(np.floor(Smax/5)+1)*5
    Lmin=Lmax-60
    Sth[:,:]=np.maximum(Sth[:,:],Lmin)
    Sph[:,:]=np.maximum(Sph[:,:],Lmin)
    return Smax,Lmax, Lmin,Sth, Sph

def productVector(ntria,N,r,d,Area,alpha,beta,vind):
    for i in range(ntria):
        A = r[vind[i, 1]-1, :]-r[vind[i, 0]-1, :]
        B = r[vind[i, 2]-1, :]-r[vind[i, 1]-1, :]
        C = r[vind[i, 0]-1, :]-r[vind[i, 2]-1, :]
        N[i, :] = -np.cross(B, A)
        d[i, 0] = np.linalg.norm(A) # edge lengths for triangle "i"
        d[i, 1] = np.linalg.norm(B)
        d[i, 2] = np.linalg.norm(C)
        ss = .5*sum(d[i, :])
        Area[i] = np.sqrt(ss*(ss-d[i, 0])*(ss-d[i, 1])*(ss-d[i, 2]))
        Nn = np.linalg.norm(N[i, :]) # unit normals
        N[i, :] = N[i, :]/Nn
        beta[i] = math.acos(N[i, 2])  # 0<beta<180, -180<phi<180
        alpha[i] = math.atan2(N[i, 1], N[i, 0])
        if(N[i, 1]==N[i, 0]==0): #porque precisou disso?
            alpha[i]=0
    return A,B,C,N,d,ss,Area, Nn, N, beta,alpha

def otherVectorComponents(ip,it,np):
    phi = np.zeros([ip, it], np.double)
    theta = np.zeros([ip, it], np.double)
    U = np.zeros([ip, it], np.double)
    V = np.zeros([ip, it], np.double)
    W = np.zeros([ip, it], np.double)
    e0 = [0,0,0]

    Sth = np.zeros([ip,it], np.double)
    Sph = np.zeros([ip,it], np.double)
    return phi, theta, U,V,W,e0, Sth,Sph