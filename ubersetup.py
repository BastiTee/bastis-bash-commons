#! /usr/bin/env python
from subprocess import Popen, PIPE, STDOUT
from os import path, mkdir
import platform
import urllib
import zipfile
from shutil import rmtree

this_directory = path.dirname(path.realpath(__file__))

PIP_INSTALL_SINGLE = 'pip install {0}'
PIP_INSTALL_FILE = 'pip install -r {0}'
PIP_LIST = 'pip list'
PIP_UNINSTALL = 'pip uninstall -y {0}'

def runcommand (command, workingdir=this_directory, suppress_output=False):
    """Run a command on the command line"""
    
    handle = Popen(command, shell=True, stdout=PIPE,
                              stderr=STDOUT, cwd=workingdir)
        
    output = []
    while handle.poll() is None:
        line = handle.stdout.readline().strip()
        if line:
            if not suppress_output:
                print line
            output.append(line)
                
    return output

def smkdir (directory):
    try:
        mkdir(directory)
    except OSError:
        pass

def ubersetup_system ():

    print '=== Preparing environment ==='
    
    ostype = platform.system()
    print 'You\'re running on a {0} box'.format(ostype)

    tmp_dir = path.join(this_directory, 'temp')
    smkdir(tmp_dir)
    
    # Install pip using python
    pip_install_script = path.join(tmp_dir, 'get-pip.py')
    urllib.urlretrieve ('https://bootstrap.pypa.io/get-pip.py', pip_install_script)
    runcommand (pip_install_script, tmp_dir)
    
    # Install python toolbox
    bptbx_dir = path.join ( tmp_dir, 'bptbx' ) 
    smkdir ( bptbx_dir )
    urllib.urlretrieve ('https://github.com/BastiTee/bastis-python-toolbox/archive/master.zip', 
                        path.join(bptbx_dir, 'bptbx.zip'))
         
    with zipfile.ZipFile(path.join(bptbx_dir, 'bptbx.zip'), 'r') as z:
        z.extractall(bptbx_dir)
     
    extracted_dir = path.join(bptbx_dir, 'bastis-python-toolbox-master')
    runcommand ( '{0} install'.format(path.join(extracted_dir, 'setup.py')), extracted_dir)
     
    runcommand(PIP_INSTALL_FILE.format(path.join(this_directory, 'setup-requirements.txt')))
    runcommand(PIP_INSTALL_FILE.format(path.join(this_directory, 'package-requirements.txt')))
    
    print '=== Resolving necessary packages available over pip ==='
 
    runcommand(PIP_INSTALL_SINGLE.format('git+git://github.com/BastiTee/bastis-python-toolbox#egg=bptbx'))
    runcommand(PIP_INSTALL_FILE.format('https://raw.githubusercontent.com/BastiTee/pyntrest/master/requirements.txt'))
    runcommand(PIP_INSTALL_FILE.format('https://raw.githubusercontent.com/BastiTee/bastis-python-toolbox/master/requirements.txt'))
     
     
     
    print '=== Finalize setup ==='
    rmtree(tmp_dir)
    
    runcommand(PIP_LIST)
    
#     
#     

def uberclear_system ():
    try:
        for line in runcommand(PIP_LIST, suppress_output=True):
            runcommand(PIP_UNINSTALL.format(line.split()[0]))
        runcommand('pip uninstall pip')
    except ImportError:
        pass

if __name__ == "__main__":
    #uberclear_system()
    ubersetup_system()


# bptbx (0.1.0)
# matplotlib (1.4.0)
