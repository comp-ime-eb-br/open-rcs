import math
import cmath
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime

def read_parameters(input_data_file):
    params = open(input_data_file, 'r')
    param_list = []
    for line in params:
        line = line.strip("\n")
        if not line.startswith("#"):
            if line.isnumeric():
                param_list.append(int(line))
            else:
                param_list.append(line)
    params.close()
    return param_list

def calculate_wave_frequency(freq):
    return 3e8 / freq

def calculate_corel(wave, corr):
    return corr / wave

def calculate_delsq(delstd):
    return delstd ** 2

def calculate_cfactors(wave, corel, delsq):
    bk = 2 * np.pi / wave
    cfac1 = np.exp(-4 * bk ** 2 * delsq)
    cfac2 = 4 * np.pi * (bk * corel) ** 2 * delsq
    return cfac1, cfac2

def process_coordinates(input_model):
    fname = f"./models/{input_model}/coordinates.txt"
    coordinates = np.loadtxt(fname)
    xpts = coordinates[:, 0]
    ypts = coordinates[:, 1]
    zpts = coordinates[:, 2]
    nverts = len(xpts)
    return xpts, ypts, zpts, nverts

def process_facets(input_model):
    fname2 = f"./models/{input_model}/facets.txt"
    facets = np.loadtxt(fname2)
    nfc = facets[:, 0]
    node1 = facets[:, 1].astype(int)
    node2 = facets[:, 2].astype(int)
    node3 = facets[:, 3].astype(int)
    ilum = facets[:, 4]
    Rs = facets[:, 5]
    ntria = len(node3)
    vind = np.empty([ntria, 3], dtype=int)
    for i in range(ntria):
        pts = np.array([node1[i], node2[i], node3[i]])
        vind[i, :] = pts
    return nfc, node1, node2, node3, ilum, Rs, ntria, vind

def create_plot_font_options():
    SMALL_SIZE = 8
    MEDIUM_SIZE = 10
    BIGGER_SIZE = 12
    plt.rc('font', size=SMALL_SIZE)
    plt.rc('axes', titlesize=MEDIUM_SIZE)
    plt.rc('axes', labelsize=SMALL_SIZE)
    plt.rc('xtick', labelsize=SMALL_SIZE)
    plt.rc('ytick', labelsize=SMALL_SIZE)
    plt.rc('legend', fontsize=SMALL_SIZE)
    plt.rc('figure', titlesize=BIGGER_SIZE)

def plot_model(input_model, xpts, ypts, zpts, nverts, vind):
    fig = plt.figure(1, [7, 4])
    fig.suptitle(f'RCS Monostatic Simulation of Target: {input_model}')
    ax = fig.add_subplot(1, 2, 1, projection='3d')
    for i in range(ntria):
        X = [xpts[vind[i, 0]-1], xpts[vind[i, 1]-1], xpts[vind[i, 2]-1], xpts[vind[i, 0]-1]]
        Y = [ypts[vind[i, 0]-1], ypts[vind[i, 1]-1], ypts[vind[i, 2]-1], ypts[vind[i, 0]-1]]
        Z = [zpts[vind[i, 0]-1], zpts[vind[i, 1]-1], zpts[vind[i, 2]-1], zpts[vind[i, 0]-1]]
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
    xmax = dmax
    ymax = dmax
    zmax = dmax
    xmin = dmin
    ymin = dmin
    zmin = dmin
    ilabv = 'n'
    ilabf = 'n'
    if ilabv == 'y':
        for i in range(nverts):
            ax.text(xpts[i]-max(xpts)/20, ypts[i]-max(ypts)/20, zpts[i], str(i+1))
    if ilabf == 'y':
        for i in range(ntria):
            xav = (xpts[node1[i]-1] + xpts[node2[i]-1] + xpts[node3[i]-1]) / 3
            yav = (ypts[node1[i]-1] + ypts[node2[i]-1] + ypts[node3[i]-1]) / 3
            zav = (zpts[node1[i]-1] + zpts[node2[i]-1] + zpts[node3[i]-1]) / 3
            ax.text(xav, yav, zav, str(nfc[i]))
    return ax, xmax, xmin, ymax, ymin, zmax, zmin

def calculate_position_vectors(xpts, ypts, zpts):
    nverts = len(xpts)
    r = np.zeros([nverts, 3], np.double)
    for i in range(nverts):
        r[i, :] = [xpts[i], ypts[i], zpts[i]]
    return r

def plot_parameters_info(ax, freq, wave, corr, delstd, pol, ntria, pstart, pstop, delp, tstart, tstop, delt):
    bx = fig.add_subplot(1, 2, 2, projection='3d')
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
    returnHere's the continued modularized code:

```python
def calculate_triangle_properties(r, vind):
    ntria = len(vind)
    Area = np.empty(ntria, np.double)
    alpha = np.empty(ntria, np.double)
    beta = np.empty(ntria, np.double)
    N = np.empty([ntria, 3], np.double)
    d = np.empty([ntria, 3], np.double)
    for i in range(ntria):
        A = r[vind[i, 1]-1, :] - r[vind[i, 0]-1, :]
        B = r[vind[i, 2]-1, :] - r[vind[i, 1]-1, :]
        C = r[vind[i, 0]-1, :] - r[vind[i, 2]-1, :]
        N[i, :] = -np.cross(B, A)
        d[i, 0] = np.linalg.norm(A)
        d[i, 1] = np.linalg.norm(B)
        d[i, 2] = np.linalg.norm(C)
        ss = .5 * sum(d[i, :])
        Area[i] = np.sqrt(ss * (ss - d[i, 0]) * (ss - d[i, 1]) * (ss - d[i, 2]))
        Nn = np.linalg.norm(N[i, :])
        N[i, :] = N[i, :] / Nn
        beta[i] = math.acos(N[i, 2])
        alpha[i] = math.atan2(N[i, 1], N[i, 0])
        if (N[i, 1] == N[i, 0] == 0):
            alpha[i] = 0
    return Area, alpha, beta, N, d

def calculate_incident_field(ip, it, pstart, pstop, delp, tstart, tstop, delt):
    phi = np.zeros([ip, it], np.double)
    theta = np.zeros([ip, it], np.double)
    U = np.zeros([ip, it], np.double)
    V = np.zeros([ip, it], np.double)
    W = np.zeros([ip, it], np.double)
    for i1 in range(ip):
        for i2 in range(it):
            phi[i1, i2] = pstart + (i1) * delp
            phr = phi[i1, i2] * rad
            theta[i1, i2] = tstart + (i2) * delt
            thr = theta[i1, i2] * rad
            u = math.sin(thr) * math.cos(phr)
            v = math.sin(thr) * math.sin(phr)
            w = math.cos(thr)
            U[i1, i2] = u
            V[i1, i2] = v
            W[i1, i2] = w
    return phi, theta, U, V, W

def calculate_special_cases(ip, it, Nt, Dp, Dq, Do, Co, Lt, cfac2, corel, wave):
    sic = 0
    if abs(Dp) < Lt and abs(Dq) >= Lt:
        specialcase = 1
        for n in range(Nt + 1):
            sic += (1j * Dp) ** n / math.factorial(n) * (-Co / (n + 1) + cmath.exp(1j * Dq) * (Co * G(n, -Dq)))
        Ic = sic * 2 * Area[m] * cmath.exp(1j * Do) / (1j * Dq)
    elif abs(Dp) < Lt and abs(Dq) < Lt:
        specialcase = 2
        sic = 0
        for n in range(Nt + 1):
            for nn in range(Nt):
                sic += (1j * Dp) ** n * (1j * Dq) ** nn / math.factorial(nn + n + 2) * Co
        Ic = sic * 2 * Area[m] * cmath.exp(1j * Do)
    elif abs(Dp) >= Lt and abs(Dq) < Lt:
        specialcase = 3
        sic = 0.0
        for n in range(Nt + 1):
            sic += (1j * Dq) ** n / math.factorial(n) * Co * G(n + 1, -Dp) / (n + 1)
        Ic = sic * 2 * Area[m] * cmath.exp(1j * Do) * cmath.exp(1j * Dp)
    elif abs(Dp) >= Lt and abs(Dq) >= Lt and abs(DD) < Lt:
        specialcase = 4
        sic = 0
        for n in range(Nt + 1):
            sic += (1j * DD) ** n / math.factorial(n) * (-Co * G(n, Dq) + cmath.exp(1j * Dq) * Co / (n + 1))
        Ic = sic * 2 * Area[m] * cmath.exp(1j * Do) / (1j * Dq)
    else:
        specialcase = 0
        Ic = 2 * Area[m] * cmath.exp(1j * Do) * (cmath.exp(1j * Dp) * Co / (Dp * DD) - cmath.exp(1j * Dq) * Co / (Dq * DD) - Co / (Dp * Dq))
    return specialcase, Ic

def calculate_scattered_field_components(Jx2, Jy2, Ic, Edif, uu, vv, ww, Es0, Es1, Es2, Ed0, Ed1, Ed2, e0, r, vind, ilum, ntria, N, wave, cfac1):
    sumt = 0
    sump = 0
    sumdt = 0
    sumdp = 0
    for m in range(ntria):
        ndotk = np.dot(N[m, :], np.transpose(R))
        if iflag == 0:
            if (ilum[m] == 1 and ndotk >= 1e-5) or ilum[m] == 0:
                T1 = np.array```python
def calculate_scattered_field_components(Jx2, Jy2, Ic, Edif, uu, vv, ww, Es0, Es1, Es2, Ed0, Ed1, Ed2, e0, r, vind, ilum, ntria, N, wave, cfac1):
    sumt = 0
    sump = 0
    sumdt = 0
    sumdp = 0
    for m in range(ntria):
        ndotk = np.dot(N[m, :], np.transpose(R))
        if iflag == 0:
            if (ilum[m] == 1 and ndotk >= 1e-5) or ilum[m] == 0:
                T1 = np.array([[math.cos(alpha[m]),  math.sin(alpha[m]),   0],
                               [-math.sin(alpha[m]), math.cos(alpha[m]),   0],
                               [0,                   0,                    1]])
                T2 = np.array([[math.cos(beta[m]), 0, -math.sin(beta[m])],
                               [0,                 1, 0],
                               [math.sin(beta[m]), 0, math.cos(beta[m])]])
                D1 = np.dot(T1, np.transpose(D0))
                D2 = np.dot(T2, D1)
                u2 = D2[0]
                v2 = D2[1]
                w2 = D2[2]
                th2 = math.asin(np.sqrt(u2 ** 2 + v2 ** 2) * np.sign(w2))
                phi2 = math.atan2(v2, u2 + 1e-10)
                if v2 == u2 + 1e-10 == 0:
                    phi2 = 0
                Dp = 2 * bk * ((x[vind[m, 0] - 1] - x[vind[m, 2] - 1]) * u +
                               (y[vind[m, 0] - 1] - y[vind[m, 2] - 1]) * v +
                               (z[vind[m, 0] - 1] - z[vind[m, 2] - 1]) * w)
                Dq = 2 * bk * ((x[vind[m, 1] - 1] - x[vind[m, 2] - 1]) * u +
                               (y[vind[m, 1] - 1] - y[vind[m, 2] - 1]) * v +
                               (z[vind[m, 1] - 1] - z[vind[m, 2] - 1]) * w)
                Do = 2 * bk * (x[vind[m, 2] - 1] * u + y[vind[m, 2] - 1] * v + z[vind[m, 2] - 1] * w)
                e1 = np.dot(T1, np.transpose(np.conj(e0)))
                e2 = np.dot(T2, e1)
                Et2 = e2[0] * math.cos(th2) * math.cos(phi2) + e2[1] * math.cos(th2) * math.sin(phi2) - e2[2] * math.sin(th2)
                Ep2 = -e2[0] * math.sin(phi2) + e2[1] * math.cos(phi2)
                perp = -1 / (2 * Rs[m] * math.cos(th2) + 1)
                para = 0
                if (2 * Rs[m] + math.cos(th2)) != 0:
                    para = -math.cos(th2) / (2 * Rs[m] + math.cos(th2))
                Jx2 = (-Et2 * math.cos(phi2) * para + Ep2 * math.sin(phi2) * perp)
                Jy2 = (-Et2 * math.sin(phi2) * para - Ep2 * math.cos(phi2) * perp)
                DD = Dq - Dp
                expDo = cmath.exp(1j * Do)
                expDp = cmath.exp(1j * Dp)
                expDq = cmath.exp(1j * Dq)
                Ic = calculate_special_cases(ip, it, Nt, Dp, Dq, Do, Co, Lt, cfac2, corel, wave)
                Es2[0] = Jx2 * Ic
                Es2[1] = Jy2 * Ic
                Es2[2] = 0
                Ed2[0] = Jx2 * Edif
                Ed2[1] = Jy2 * Edif
                Ed2[2] = 0
                Es1 = np.dot(np.transpose(T2), np.transpose(Es2))
                Es0 = np.dot(np.transpose(T1), Es1)
                Ed1 = np.dot(np.transpose(T2), np.transpose(Ed2))
                Ed0 = np.dot(np.transpose(T1), Ed1)
                Ets = uu * Es0[0] + vv * Es0[1] + ww * Es0[2]
                Eps = -math.sin(phr) * Es0[0] + math.cos(phr) * Es0[1]
                Etd = uu * Ed0[0] + vv * Ed0[1] + ww * Ed0[2]
                Epd = -math.sin(phr) * Ed0[0] + math.cos(phr) * Ed0[1]
                sumt += Ets
                sumdt += abs(Etd)
                sump += Eps
                sumdp += abs(Epd)
    return sumt, sumdt, sump, sumdp

def generate_result_files(input_model, now, param, theta, Sth, phi, Sph):
    result_file = open("./results/" + "RCSSimulator_Monostatic_" + "_" + now + ".dat", 'w')
    result_file.write("RCS SIMULATOR MONOSTATIC " + now + "\n")
    result_file.write("\nSimulation Parameters:\n" + param)
    result_file.write("\nSimulation Results IR Signature:")
    result_file.write("\nTheta (deg):\n")
    for i1 in range(ip):
        result_file.write(str(theta[i1]) + "\n")
    result_file.write("\nRCS Theta (dBsm):\n")
    for i1 in range(ip):
        result_file.write(str(Sth[i1]) + "\n")
    result_file.write("\nPhi (deg):\n")
    for i1 in range(ip):
        result_file.write(str(phi[i1]) + "\n")
    result_file.write("\nRCS Phi (dBsm):\n")
    for i1 in range(ip):
        result_file.write(str(Sph[i1]) + "\n")
    result_file.close()

def plot_final_results(ip, it, Sth, Sph, Lmin, Lmax, theta, phi):
    if ip == 1:
        plt.figure(1)
        plt.suptitle("RCSMonostatic Simulation Results")

        plt.subplot(2, 1, 1)
        plt.plot(phi, Sph, "b-")
        plt.xlabel("Phi (deg)")
        plt.ylabel("RCS Phi (dBsm)")
        plt.grid(True)

        plt.subplot(2, 1, 2)
        plt.plot(theta, Sth, "r-")
        plt.xlabel("Theta (deg)")
        plt.ylabel("RCS Theta (dBsm)")
        plt.grid(True)

        plt.tight_layout()
        plt.savefig(f"./results/RCSSimulator_Monostatic_{now}.png")
        plt.show()

def main():
    input_data_file = "./input_data.txt"
    input_model = read_parameters(input_data_file)[0]

    freq = read_parameters(input_data_file)[1]
    wave = calculate_wave_frequency(freq)
    corr = read_parameters(input_data_file)[2]
    delstd = read_parameters(input_data_file)[3]
    pol = read_parameters(input_data_file)[4]

    xpts, ypts, zpts, nverts = process_coordinates(input_model)
    nfc, node1, node2, node3, ilum, Rs, ntria, vind = process_facets(input_model)

    create_plot_font_options()
    ax, xmax, xmin, ymax, ymin, zmax, zmin = plot_model(input_model, xpts, ypts, zpts, nverts, vind)

    r = calculate_position_vectors(xpts, ypts, zpts)
    Area, alpha, beta, N, d = calculate_triangle_properties(r, vind)

    phi, theta, U, V, W = calculate_incident_field(ip, it, pstart, pstop, delp, tstart, tstop, delt)

    Jx2 = 0
    Jy2 = 0
    Ic = 0
    Edif = 1
    Es0 = np.zeros(3, dtype=np.complex_)
    Es1 = np.zeros(3, dtype=np.complex_)
    Es2 = np.zeros(3, dtype=np.complex_)
    Ed0 = np.zeros(3, dtype=np.complex_)
    Ed1 = np.zeros(3, dtype=np.complex_)
    Ed2 = np.zeros(3, dtype=np.complex_)
    Ets = 0
    Eps = 0
    Etd = 0
    Epd = 0

    sumt, sumdt, sump, sumdp = calculate_scattered_field_components(Jx2, Jy2, Ic, Edif, uu, vv, ww, Es0, Es1, Es2, Ed0, Ed1, Ed2, e0, r, vind, ilum, ntria, N, wave, cfac1)

    Sth = 10 * np.log10(sumdt / abs(Etd) ** 2)
    Sph = 10 * np.log10(sumdp / abs(Epd) ** 2)

    Lmin = min(Sth.min(), Sph.min())
    Lmax = max(Sth.max(), Sph.max())

    now = datetime.now().strftime("%Y%m%d%H%M%S")
    param = f"Radar Frequency (GHz): {freq / 1e9}\nWavelength (m): {wave}\nCorrelation distance (m): {corr}\nStandard Deviation (m): {delstd}\nIncident wave polarization: {pol}\nNumber of model faces: {ntria}\nStart phi angle (degrees): {pstart}\nStop phi angle (degrees): {pstop}\nPhi increment step (degrees): {delp}\nStart theta angle (degrees): {tstart}\nStop theta angle (degrees): {tstop}\nPhi increment step (degrees): {delt}\n"

    generate_result_files(input_model, now, param, theta, Sth, phi, Sph)

    plot_final_results(ip, it, Sth, Sph, Lmin, Lmax, theta, phi)

if __name__ == "__main__":
    main()
