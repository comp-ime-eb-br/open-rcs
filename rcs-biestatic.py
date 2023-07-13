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
    fname = "./models/" + input_model + "/coordinates.txt"
    coordinates = np.loadtxt(fname)
        # Define the scale factor
    scl = 1

    # Check if scaling is desired
    if scl != 1:
        print('dimensions have been scaled by a factor of', scl)

    # Rescale the coordinates
    xpts = coordinates[:, 0] * scl
    ypts = coordinates[:, 1] * scl
    zpts = coordinates[:, 2] * scl

    x = xpts
    y = ypts
    z = zpts

    nverts = len(xpts)
    return x, y, z, xpts, ypts, zpts, nverts

def read_facets(input_model):
    fname2 = "./models/" + input_model + "/facets.txt"
    facets = np.loadtxt(fname2)
    nfc = facets[:, 0]
    node1 = facets[:, 1].astype(int)
    node2 = facets[:, 2].astype(int)
    node3 = facets[:, 3].astype(int)
    iflag = 0
    ilum = facets[:, 4]
    Rs = facets[:, 5]
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

def plot_triangle_model(ax, vind, x, y, z, xpts, ypts, zpts, nverts, ntria, node1, node2, node3, nfc, ilabv, ilabf):
    for i in range(ntria):
        X = [x[vind[i, 0]-1], x[vind[i, 1]-1], x[vind[i, 2]-1], x[vind[i, 0]-1]]
        Y = [y[vind[i, 0]-1], y[vind[i, 1]-1], y[vind[i, 2]-1], y[vind[i, 0]-1]]
        Z = [z[vind[i, 0]-1], z[vind[i, 1]-1], z[vind[i, 2]-1], z[vind[i, 0]-1]]
        ax.plot(X, Y, Z)
    ax.set_title(f'Triangle Model of Target:')
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
    return xmin, ymin, zmin, xmax, ymax, zmax

def diretionCosines(alpha, beta, D0i):
    T1=np.array([[math.cos(alpha[m]),  math.sin(alpha[m]),   0],
                    [-math.sin(alpha[m]), math.cos(alpha[m]),   0],
                    [0,                   0,                    1]])
    T2=np.array([[math.cos(beta[m]), 0, -math.sin(beta[m])],
                    [0,                 1, 0],
                    [math.sin(beta[m]), 0, math.cos(beta[m])]])
    # Calcula D1i
    D1i = np.dot(T1, D0i.T)

    # Calcula D2i
    D2i = np.dot(T2, D1i)

    # Extrai os valores de ui2, vi2 e wi2
    ui2 = D2i[0]
    vi2 = D2i[1]
    wi2 = D2i[2]
    return ui2, vi2, wi2, T1, T2

def deg2rad(deg):
 return deg * np.pi / 180.0

def calculate_values(pstart, pstop, delp, tstart, tstop, delt, ntria, rad, fii,thetai):

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

def globalAngles(thr,phr,i1,i2):
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

def incidentFieldCartesian(uu,vv,ww,Et,phr,Ep,uui,vvi,wwi):
    e0[0] = uui * Et - spi * Ep
    e0[1] = vvi * Et + cpi * Ep
    e0[2] = wwi * Et
    return e0

def sphericalAngles(ui2,vi2,wi2):
    # Calcula sti2
    sti2 = np.sqrt(ui2**2 + vi2**2) * np.sign(wi2)

    # Calcula cti2
    cti2 = np.sqrt(1 - sti2**2)

    # Calcula phii2
    phii2 = np.arctan2(vi2, ui2 + 1e-10)

    # Calcula thi2
    thi2 = np.arccos(cti2)

    # Calcula cpi2 e spi2
    cpi2 = np.cos(phii2)
    spi2 = np.sin(phii2)
    return thi2, phii2

def calculaCoisas(ui2,vi2,wi2):
    # Calcula sti2
    sti2 = np.sqrt(ui2**2 + vi2**2) * np.sign(wi2)

    # Calcula cti2
    cti2 = np.sqrt(1 - sti2**2)

    # Calcula phii2
    phii2 = np.arctan2(vi2, ui2 + 1e-10)

    # Calcula thi2
    thi2 = np.arccos(cti2)

    # Calcula cpi2 e spi2
    cpi2 = np.cos(phii2)
    spi2 = np.sin(phii2)
    return cpi2,spi2


def phaseVerticeTriangle(x,y,z,vind,bk,m,u,v,w,ui,vi,wi):
     # Calcula Dp
    Dp = bk * ((x[vind[m, 0]] - x[vind[m, 2]]) * (u + ui) +(y[vind[m, 0]] - y[vind[m,2]]) * (v + vi) + (z[vind[m, 0]] - z[vind[m, 2]]) * (w + wi))

    # Calcula Dq
    Dq = bk * ((x[vind[m, 1]] - x[vind[m, 2]]) * (u + ui) + (y[vind[m, 1]] - y[vind[m,2]]) * (v + vi) + (z[vind[m, 1]] - z[vind[m, 2]]) * (w + wi))

    # Calcula Do
    Do = bk * ( x[vind[m, 2]] * (u + ui) + y[vind[m, 2]] * (v + vi) + z[vind[m, 2]] * (w - wi))
    return(Dp,Dq,Do)

def G(n,w):
                        jw=1j*w
                        g=(np.exp(jw)-1)/jw
                        if n > 0:
                            for m in range(1,n+1):
                                go=g
                                g=(cmath.exp(jw)-n*go)/jw
                        return g

def reflectionCoefficients(Rs, th2):
                        perp=-1/(2*Rs[m]*math.cos(th2)+1)  #local TE polarization
                        para=0  #local TM polarization
                        if (2*Rs[m]+math.cos(th2))!=0:
                            para=-math.cos(th2)/(2*Rs[m]+math.cos(th2))
                        return perp, para

def incidentFieldSphericalCoordinates(th2,e2,phi2):
                        Et2=e2[0]*math.cos(th2)*math.cos(phi2)+e2[1]*math.cos(th2)*math.sin(phi2)-e2[2]*math.sin(th2)
                        Ep2=-e2[0]*math.sin(phi2)+e2[1]*math.cos(phi2)
                        return Et2, Ep2

def finalPlot(ip, it,phi, wave,theta, Lmin,Lmax,Sth,Sph,U,V,now):
    if ip==1:
        plt.figure(1)
        plt.suptitle("RCS Simulation IR Signature")
        plt.title(f"target: {input_model}   solid: theta     dashed: phi     phi= {phi[0][0]}    wave (m): {wave}")
        plt.xlabel("Monostatic Angle, theta (deg)")
        plt.ylabel("RCS (dBsm)")
        plt.axis([np.min(theta),np.max(theta),Lmin,Lmax])
        plt.plot(theta[0],Sth[0])
        plt.plot(theta[0],Sph[0],linestyle="dashed")
        plt.grid(True)
        
    if it==1:
        plt.figure(1)
        plt.suptitle("RCS Simulation IR Signature")
        plt.title(f"target: {input_model}   solid: theta     dashed: phi     theta= {theta[0][0]}    wave (m): {wave}")
        plt.xlabel('Monostatic Angle, phi (deg)')
        plt.ylabel('RCS (dBsm)')
        plt.axis([np.min(phi), np.max(phi), Lmin, Lmax])
        plt.plot(phi[0],Sth[0])
        plt.plot(phi[0],Sph[0],linestyle="dashed")
        plt.grid(True)
        
    if ip>1 and it>1:
        fig = plt.figure(1,[10,4])
        fig.suptitle("RCS Simulation IR Signature")
        
        ax=fig.add_subplot(1,2,1)
        cp=ax.contour(U, V, Sth)
        ax.set_title('RCS-theta')
        ax.set_xlabel('U')
        ax.set_ylabel('V')
        ax.axis('square')
        cbar=fig.colorbar(cp)
        cbar.set_label('RCS (dBsm)')
        
        bx=fig.add_subplot(1,2,2)
        cp=bx.contour(U, V, Sph)
        bx.set_title('RCS-phi')
        bx.set_xlabel('U')
        bx.set_ylabel('V')
        bx.axis('square')
        cbar=fig.colorbar(cp)
        cbar.set_label('RCS (dBsm)')
        
    plt.savefig("./results/"+"RCSSimulator_Monostatic_"+"_"+now+".png")
    plt.show()

def generateResultFiles(theta, Sth, phi,Sph):
    now = datetime.now().strftime("%Y%m%d%H%M%S")
    result_file = open("./results/"+"RCSSimulator_Monostatic_"+"_"+now+".dat", 'w')

    result_file.write("RCS SIMULATOR MONOSTITC "+now+"\n")
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
    return now
        
def areaIntegral(Dq, Dp,Do):
                        DD=Dq-Dp
                        expDo=cmath.exp(1j*Do)
                        expDp=cmath.exp(1j*Dp)
                        expDq=cmath.exp(1j*Dq)
                        return DD, expDo, expDp, expDq

def calculate_Ic(Dp,Dq,Do,N, Nt,Area, expDo,Co,Lt,DD,expDq):
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

def plotParameters(wave,corr,delstd, pol,ntria,pstart,pstop,delp,tstart,tstop,delt):
    bx = fig.add_subplot(1,2,2,projection='3d')
    bx.set_axis_off()
    bx.set_title(f'Simulation Parameters:') 
    param = f'Radar Frequency (GHz): {freq/1e9}\n\
    Wavelength (m): {wave}\n\
    Correlation distance (m): {corr}\n\
    Standard Deviation (m): {delstd}\n\
    Incident wave polarization: {pol}\n\
    Number of model faces: {ntria}\n\
    Start phi angle (degrees): {pstart}\n\
    Stop phi angle (degrees): {pstop}\n\
    Phi increment step (degrees): {delp}\n\
    Start theta angle (degrees): {tstart}\n\
    Stop theta angle (degrees): {tstop}\n\
    Phi increment step (degrees): {delt}\n'
    bx.text(0, 0, 0, param)
    return param

def calculaCampos(Area, cfac2, corel, th2, wave,Jy2,Ic,uu,vv,ww,phr,sumt,sump,sumdt,sumdp):
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

def calculateSth_Sph(cfac1,sumt,sump,sumdt,wave):          
            Sth[i1,i2]=10*np.log10(4*np.pi*cfac1*(np.abs(sumt)**2+np.sqrt(1-cfac1**2)*sumdt)/wave**2+1e-10)
            Sph[i1,i2]=10*np.log10(4*np.pi*cfac1*(np.abs(sump)**2+np.sqrt(1-cfac1**2)*sumdp)/wave**2+1e-10)
            return Sth, Sph

def parametrosGrafico():
    Smax=max(np.max(Sth),np.max(Sph))
    Lmax=(np.floor(Smax/5)+1)*5
    Lmin=Lmax-60
    Sth[:,:]=np.maximum(Sth[:,:],Lmin)
    Sph[:,:]=np.maximum(Sph[:,:],Lmin)
    return Smax,Lmax, Lmin,Sth, Sph

def productVector(ntria,r,vind):
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

# open input data file and gather parameters
# input_model="BOX"
input_data_file = "input_data_file.dat"
params = open(input_data_file, 'r')
param_list = []
for line in params:
    line=line.strip("\n")
    if not line.startswith("#"):
        if line.isnumeric(): param_list.append(int(line))
        else: param_list.append(line)
input_model, freq, corr, delstd, ipol, pstart, pstop, delp, tstart, tstop, delt = param_list
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
param = plotParameters(wave,corr,delstd, pol,ntria,pstart,pstop,delp,tstart,tstop,delt)
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
fii=0
thetai=0
Area, alpha, beta, N, d, ip, it ,cpi,spi,sti,cti,ui,vi,wi,D0i,uui,vvi,wwi,Ri = calculate_values(pstart, pstop, delp, tstart, tstop, delt, ntria, rad,fii,thetai)
# get edge vectors and normals from edge cross products


A,B,C,N,d,ss,Area, Nn, N, beta,alpha =  productVector(ntria,r,vind)
phi, theta, U,V,W,e0, Sth,Sph = otherVectorComponents(ip,it,np)
for i1 in range(ip):
    for i2 in range(it):
        phi[i1,i2]=pstart+(i1)*delp
        phr=phi[i1,i2]*rad
        theta[i1,i2]=tstart+(i2)*delt
        thr=theta[i1,i2]*rad
        # global angles and direction cosine
        U, V, W, D0, uu, vv, ww, u, v, w = globalAngles(thr,phr,i1,i2)
        # spherical coordinate system radial unit vector
        R=np.array([u,v,w])
        # incident field in global cartesian coordinates
        e0  = incidentFieldCartesian(uu,vv,ww,Et,phr,Ep,uui,vvi,wwi)
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
                    ui2, vi2, wi2, T1, T2 = diretionCosines(alpha, beta, D0i)

                    # find spherical angles in local coordinates
                    thi2, phii2 = sphericalAngles(ui2,vi2,wi2)

                    cpi2,spi2 = calculaCoisas(ui2,vi2,wi2)
                    # phase at the three vertices of triangle m; monostatic RCS needs "2"
                    Dp,Dq,Do = phaseVerticeTriangle(x,y,z,vind,bk,m,u,v,w,ui,vi,wi)
                    # incident field in local cartesian coordinates (stored in e2)
                    e1=np.dot(T1,np.transpose(np.conj(e0)))
                    e2=np.dot(T2,e1)

                    # incident field in local spherical coordinates
                    Et2, Ep2 = incidentFieldSphericalCoordinates(thi2,e2,phii2)

                    # reflection coefficients (Rs is normalized to eta0)
                    perp, para = reflectionCoefficients(Rs, thi2)

                    # surface current components in local Cartesian coordinates
                    Jx2=(-Et2*math.cos(phii2)*para+Ep2*math.sin(phii2)*perp);   # math.cos(th2) removed
                    Jy2=(-Et2*math.sin(phii2)*para-Ep2*math.cos(phii2)*perp);   # math.cos(th2) removed

                    # area integral for general case
                    DD, expDo, expDp, expDq = areaIntegral(Dq, Dp,Do)

                    Ic = calculate_Ic(Dp,Dq,Do,N, Nt,Area, expDo,Co,Lt,DD,expDq)
                    sumt,sump,sumdp,sumdt = calculaCampos(Area, cfac2, corel, thi2, wave,Jy2,Ic,uu,vv,ww,phr,sumt,sump,sumdt,sumdp)
        Sth, Sph = calculateSth_Sph(cfac1,sumt,sump,sumdt,wave) 
Smax,Lmax, Lmin,Sth, Sph = parametrosGrafico()

# generate result files
now = generateResultFiles(theta, Sth, phi,Sph)

# final plots
finalPlot(ip, it,phi, wave,theta, Lmin,Lmax,Sth,Sph,U,V,now)