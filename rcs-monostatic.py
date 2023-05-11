import math, cmath
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime

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
delsq = delstd ** 2
bk = 2 * np.pi / wave
cfac1 = np.exp(-4 * bk ** 2 * delsq)
cfac2 = 4 * np.pi * (bk * corel) ** 2 * delsq
rad = np.pi / 180
Lt = 0.05  # taylor series region
Nt = 5 # number of terms in Taylor series

# 4: incident wave polarization
if ipol == 0: # Theta-polarized (TM-z) 
    pol = 'TM-z'
    Et = 1 + 1j * 0   
    Ep = 0 + 1j * 0
elif ipol == 1: # Phi-polarized (TE-z)
    pol = 'TE-z'
    Et = 0 + 1j * 0   
    Ep = 1 + 1j * 0
else:
    raise ValueError('Invalid input')
Co=1  # wave amplitude at all vertices

# processing coordinate data 
fname = "./models/"+input_model+"/coordinates.m"
coordinates = np.loadtxt(fname)
xpts = coordinates[:, 0]
ypts = coordinates[:, 1]
zpts = coordinates[:, 2]
nverts = len(xpts)

fname2 = "./models/"+input_model+"/facets.m"
facets = np.loadtxt(fname2)
nfc = facets[:, 0]
node1 = facets[:, 1].astype(int)
node2 = facets[:, 2].astype(int)
node3 = facets[:, 3].astype(int)
iflag = 0           # illumination flag: iflag = 0, external face only
ilum = facets[:, 4] # illumination flags for each triangle
Rs = facets[:, 5]   # resistivity of each triangle
ntria = len(node3)

vind = np.empty([ntria, 3])
for i in range(ntria):
    pts = np.array([node1[i], node2[i], node3[i]])
    vind[i, :] = pts
vind = vind.astype(int)

x = xpts
y = ypts
z = zpts

r = np.zeros([nverts, 3], np.double) # define position vectors to vertices
for i in range(nverts):
    r[i, :] = [x[i], y[i], z[i]]

# plot font options
SMALL_SIZE = 8
MEDIUM_SIZE = 10
BIGGER_SIZE = 12
plt.rc('font', size=SMALL_SIZE)          # controls default text sizes
plt.rc('axes', titlesize=MEDIUM_SIZE)    # fontsize of the axes title
plt.rc('axes', labelsize=SMALL_SIZE)     # fontsize of the x and y labels
plt.rc('xtick', labelsize=SMALL_SIZE)    # fontsize of the tick labels
plt.rc('ytick', labelsize=SMALL_SIZE)    # fontsize of the tick labels
plt.rc('legend', fontsize=SMALL_SIZE)    # legend fontsize
plt.rc('figure', titlesize=BIGGER_SIZE)  # fontsize of the figure title

# plot model before simulation
fig = plt.figure(1,[7,4])
fig.suptitle(f'RCS Monostatic Simulation of Target: BOX')

# plot triangle model
ax = fig.add_subplot(1,2,1, projection='3d')
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

ilabv ='n'; ilabf='n' # label vertices and faces
if ilabv == 'y':
    for i in range(nverts):
        ax.text(x[i]-max(x)/20, y[i]-max(y)/20, z[i], str(i+1))
if ilabf == 'y':
    for i in range(ntria): # compute centroid of face number i
        xav = (xpts[node1[i]-1] + xpts[node2[i]-1] + xpts[node3[i]-1]) / 3
        yav = (ypts[node1[i]-1] + ypts[node2[i]-1] + ypts[node3[i]-1]) / 3
        zav = (zpts[node1[i]-1] + zpts[node2[i]-1] + zpts[node3[i]-1]) / 3
        ax.text(xav, yav, zav, str(nfc[i]))


# plot parameters info
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
if delp == 0:
    ip = int((pstop - pstart)) + 1 # number of vertical rotations in the simulation
else:
    ip = int((pstop - pstart) / delp) + 1 
if pstart == pstop:
    phr0 = pstart * rad
if delt == 0:
    it = int((tstop - tstart)) + 1 # number of horizontal rotations in the simulation
else:
    it = int((tstop - tstart) / delt) + 1
if tstart == tstop:
    thr0 = tstart * rad

Area =  np.empty(ntria, np.double)
alpha =  np.empty(ntria, np.double)
beta = np.empty(ntria, np.double)
N = np.empty([ntria, 3], np.double)
d = np.empty([ntria, 3], np.double)

# get edge vectors and normals from edge cross products
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

phi = np.zeros([ip, it], np.double)
theta = np.zeros([ip, it], np.double)
U = np.zeros([ip, it], np.double)
V = np.zeros([ip, it], np.double)
W = np.zeros([ip, it], np.double)
e0 = [0,0,0]

Sth = np.zeros([ip,it], np.double)
Sph = np.zeros([ip,it], np.double)
for i1 in range(ip):
    for i2 in range(it):
        phi[i1,i2]=pstart+(i1)*delp
        phr=phi[i1,i2]*rad
        theta[i1,i2]=tstart+(i2)*delt
        thr=theta[i1,i2]*rad

        # global angles and direction cosines
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

        # spherical coordinate system radial unit vector
        R=np.array([u,v,w])
        # incident field in global cartesian coordinates
        e0[0]=uu*Et-math.sin(phr)*Ep
        e0[1]=vv*Et+math.cos(phr)*Ep
        e0[2]=ww*Et

        # begin loop over triangles
        sumt=0
        sump=0
        sumdt=0
        sumdp=0

        for m in range(ntria): # test to see if front face is illuminated
            ndotk=np.dot(N[m,:],np.transpose(R))
            if iflag==0:
                if (ilum[m]==1 and ndotk>=1e-5) or ilum[m]==0:
                    # local direction cosines
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

                    # find spherical angles in local coordinates
                    th2=math.asin(np.sqrt(u2**2+v2**2)*np.sign(w2))
                    phi2=math.atan2(v2,u2+1e-10)
                    if(v2==u2+1e-10==0): #porque precisou disso?
                        phi2=0

                    # phase at the three vertices of triangle m; monostatic RCS needs "2"
                    Dp=2*bk*((x[vind[m,0]-1]-x[vind[m,2]-1])*u+
                             (y[vind[m,0]-1]-y[vind[m,2]-1])*v+
                             (z[vind[m,0]-1]-z[vind[m,2]-1])*w)
                    Dq=2*bk*((x[vind[m,1]-1]-x[vind[m,2]-1])*u+
                             (y[vind[m,1]-1]-y[vind[m,2]-1])*v+
                             (z[vind[m,1]-1]-z[vind[m,2]-1])*w)
                    Do=2*bk*(x[vind[m,2]-1]*u + y[vind[m,2]-1]*v + z[vind[m,2]-1]*w)
                    
                    # incident field in local cartesian coordinates (stored in e2)
                    e1=np.dot(T1,np.transpose(np.conj(e0)))
                    e2=np.dot(T2,e1)
                    # incident field in local spherical coordinates
                    Et2=e2[0]*math.cos(th2)*math.cos(phi2)+e2[1]*math.cos(th2)*math.sin(phi2)-e2[2]*math.sin(th2)
                    Ep2=-e2[0]*math.sin(phi2)+e2[1]*math.cos(phi2)

                    # reflection coefficients (Rs is normalized to eta0)
                    perp=-1/(2*Rs[m]*math.cos(th2)+1)  #local TE polarization
                    para=0  #local TM polarization
                    if (2*Rs[m]+math.cos(th2))!=0:
                        para=-math.cos(th2)/(2*Rs[m]+math.cos(th2))

                    # surface current components in local Cartesian coordinates
                    Jx2=(-Et2*math.cos(phi2)*para+Ep2*math.sin(phi2)*perp);   # math.cos(th2) removed
                    Jy2=(-Et2*math.sin(phi2)*para-Ep2*math.cos(phi2)*perp);   # math.cos(th2) removed

                    # area integral for general case
                    DD=Dq-Dp
                    expDo=cmath.exp(1j*Do)
                    expDp=cmath.exp(1j*Dp)
                    expDq=cmath.exp(1j*Dq)

                    def G(n,w):
                        jw=1j*w
                        g=(np.exp(jw)-1)/jw
                        if n > 0:
                            for m in range(1,n+1):
                                go=g
                                g=(cmath.exp(jw)-n*go)/jw
                        return g

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
                    
        Sth[i1,i2]=10*np.log10(4*np.pi*cfac1*(np.abs(sumt)**2+np.sqrt(1-cfac1**2)*sumdt)/wave**2+1e-10)
        Sph[i1,i2]=10*np.log10(4*np.pi*cfac1*(np.abs(sump)**2+np.sqrt(1-cfac1**2)*sumdp)/wave**2+1e-10)
        
Smax=max(np.max(Sth),np.max(Sph))
Lmax=(np.floor(Smax/5)+1)*5
Lmin=Lmax-60
Sth[:,:]=np.maximum(Sth[:,:],Lmin)
Sph[:,:]=np.maximum(Sph[:,:],Lmin)

# generate result files
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


# final plots
if ip==1:
    plt.figure(1)
    plt.suptitle("RCS Simulation IR Signature")
    plt.title(f"target: BOX   solid: theta     dashed: phi     phi= {phi[0][0]}    wave (m): {wave}")
    plt.xlabel("Monostatic Angle, theta (deg)")
    plt.ylabel("RCS (dBsm)")
    plt.axis([np.min(theta),np.max(theta),Lmin,Lmax])
    plt.plot(theta[0],Sth[0])
    plt.plot(theta[0],Sph[0],linestyle="dashed")
    plt.grid(True)
    
if it==1:
    plt.figure(1)
    plt.suptitle("RCS Simulation IR Signature")
    plt.title(f"target: BOX   solid: theta     dashed: phi     theta= {theta[0][0]}    wave (m): {wave}")
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
