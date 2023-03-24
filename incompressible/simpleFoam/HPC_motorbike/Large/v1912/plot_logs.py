import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('pdf')

from matplotlib import gridspec
from matplotlib.ticker import MaxNLocator

import numpy as np

import os
if os.path.exists('FIGS/') == False:
    os.mkdir('FIGS/')
        
gs  = gridspec.GridSpec(2, 3, width_ratios=[1,1,1], height_ratios=[1,1]) 

fig = plt.figure(figsize=(15,10))
ax  = [ plt.subplot(gs[i]) for i in range(6) ]

fieldID = 0
for field in ['Ux', 'Uy', 'Uz', 'p', 'k', 'omega']:
    data = np.loadtxt('logs/%s_0'%(field))
    ax[fieldID].plot(data[:,0], data[:,1], linewidth=1)
    ax[fieldID].set_yscale('log')    
    ax[fieldID].set_ylabel('Residual')   
    ax[fieldID].set_xlabel('Step')
    ax[fieldID].set_title(field)
    fieldID += 1

fig.savefig('FIGS/fieldResiduals.png', dpi=200, bbox_inches='tight')    
plt.close()

##----------------------------------------------------------------------------------------

gs  = gridspec.GridSpec(2, 3, width_ratios=[1,1,1], height_ratios=[1,1]) 

fig = plt.figure(figsize=(15,10))
ax  = [ plt.subplot(gs[i]) for i in range(6) ]

fieldID = 0
for field in ['Ux', 'Uy', 'Uz', 'p', 'k', 'omega']:
    data = np.loadtxt('logs/%sIters_0'%(field))
    ax[fieldID].plot(data[:,0], data[:,1], linewidth=1)
    ax[fieldID].set_ylabel('Iters')   
    ax[fieldID].set_xlabel('Step')
    ax[fieldID].set_title(field)
    ax[fieldID].yaxis.set_major_locator(MaxNLocator(integer=True))
    
    if fieldID > 3:
        ax[fieldID].set_ylim(ymin=0, ymax=2)
    
    fieldID += 1

fig.savefig('FIGS/fieldIterSol.png', dpi=200, bbox_inches='tight')    
plt.close()

##----------------------------------------------------------------------------------------

fig = plt.figure(figsize=(5,5))
ax  = fig.gca()

data = np.loadtxt('logs/executionTime_0'))
ax.plot(data[:,0], data[:,1], linewidth=1)
  
ax.set_ylabel('Time [s]')   
ax.set_xlabel('Step')
ax.set_title('Execution time')

fig.savefig('FIGS/executionTime.png', dpi=200, bbox_inches='tight')    
plt.close()
